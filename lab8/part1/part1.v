//
// This is the template for Part 1 of Lab 8.
//
// Paul Chow
// November 2021
// Updated November 2022
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREEN_PIXELS, Y_SCREEN_PIXELS are the dimensions of the screen
//       Default is 160 x 120, which is the baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part1(iColour,iResetn,iClock,oX,oY,oColour,oPlot,oNewFrame);
   input wire [2:0] iColour;
   input wire 	    iResetn;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel drawn enable
   output wire       oNewFrame;    // goes high for 1 cycle when a new frame starts

   parameter
     X_SCREEN_PIXELS = 160,  // X screen width for starting resolution
     Y_SCREEN_PIXELS = 120,  // Y screen height for starting resolution
     CLOCKS_PER_SECOND = 50_000_000, // 5 KHZ 
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_MAX = X_SCREEN_PIXELS - 1 - (X_BOXSIZE-1), // 0-based and account for box width
     Y_MAX = Y_SCREEN_PIXELS - 1 - (Y_BOXSIZE-1),
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60
	       ;

   //
   // Your code goes here
   wire ld_black, draw_box, update_box;
   wire [3:0] offset_count, fcount;

   DelayCounter #(.PULSES_PER_SIXTIETH_SECOND(PULSES_PER_SIXTIETH_SECOND)) dc(.clk(iClock), .resetn(iResetn), .dcount_en(oNewFrame));
   FrameCounter fc(.clk(iClock), .resetn(iResetn), .dcount_en(oNewFrame), .fcount(fcount));

   control c0(.iClock(iClock), .iResetn(iResetn), .offset_count(offset_count), .fcount(fcount),
               .ld_black(ld_black), .draw_box(draw_box), .oPlot(oPlot), .update_box(update_box)
               );
   
   datapath #(.X_MAX(X_MAX), .Y_MAX(Y_MAX)) d0(.iResetn(iResetn), .iClock(iClock), .iColour(iColour),
               .ld_black(ld_black), .draw_box(draw_box), .update_box(update_box),
               .oX(oX), .oY(oY), .oColour(oColour), .offset_count(offset_count)
               );

   //


endmodule // part1

module DelayCounter(input clk, resetn, output dcount_en);
   reg [20:0] dcount;

   parameter PULSES_PER_SIXTIETH_SECOND = 0;

   assign dcount_en = (dcount == /*PULSES_PER_SIXTIETH_SECOND*/0);
   
   always @(posedge clk)
   begin
      if(!resetn) dcount <= 0;
      else if (dcount == PULSES_PER_SIXTIETH_SECOND-1) dcount <= 0;
      else dcount <= dcount + 1;
   end
endmodule

module FrameCounter(input clk, resetn, dcount_en, 
                    output reg [3:0] fcount);
   
   always @(posedge clk)
   begin
      if (!resetn) fcount <= 0;
      else if (fcount == (15-1) && dcount_en) fcount <= 0;
      else if (dcount_en) fcount <= fcount + 1;
   end
endmodule


module control(input iClock, iResetn,
               input [3:0] offset_count,
               input [3:0] fcount,
               output reg ld_black, draw_box, oPlot, update_box
               );

   parameter S_WAIT_FOR_RESET = 0,
             S_RESET = 1,
             S_DRAW_BOX = 2,
             S_WAIT = 3, // wait until next refresh cycle
             S_CLEAR_BOX = 4,
             S_UPDATE = 5,
             S_UPDATE_WAIT = 6;

   reg [2:0] current_state = 0, next_state = 0;

   always @(*)
   begin: state_table
      case (current_state)
         S_WAIT_FOR_RESET: next_state = (!iResetn) ? /*S_RESET*/S_DRAW_BOX : S_WAIT_FOR_RESET;
         //S_RESET: next_state = (!iResetn) ? S_DRAW_BOX : S_RESET;
         S_DRAW_BOX: next_state = (offset_count == 4'b1111) ? S_WAIT : S_DRAW_BOX;
         S_WAIT: next_state = (fcount == 'd14) ? S_CLEAR_BOX : S_WAIT;
         S_CLEAR_BOX: next_state = (offset_count == 4'b1111) ? S_UPDATE : S_CLEAR_BOX;
         S_UPDATE: next_state = S_UPDATE_WAIT;
         S_UPDATE_WAIT: next_state = (fcount == 'd0) ? S_DRAW_BOX : S_UPDATE_WAIT;
      endcase
   end

   always @(*)
   begin: enable_signals

      ld_black = 0;
      oPlot = 0;
      draw_box = 0;
      update_box = 0;
      
      case (current_state)
         S_WAIT_FOR_RESET: begin
            // Do nothing
         end
         S_RESET: begin
            // Do nothing, signals are being reset.
         end
         S_DRAW_BOX: begin
            draw_box = 1;
            oPlot = 1;
         end
         S_WAIT: begin
            // Do nothing
         end
         S_CLEAR_BOX: begin // Draw black box at current location
            ld_black = 1;
            draw_box = 1;
            oPlot = 1;
         end
         S_UPDATE: begin
            update_box = 1;
         end
         S_UPDATE_WAIT: begin
            // Do nothing, wait for next frame.
         end
      endcase
   end

   always @(posedge iClock) begin
      current_state <= next_state;
   end


endmodule


module datapath(input iResetn, iClock,
                input [2:0] iColour,
                input ld_black, draw_box, update_box,
                output reg [7:0] oX, 
                output reg [6:0] oY,
                output reg [2:0] oColour,
                output reg [3:0] offset_count
                );
   parameter X_MAX = 0, // 0-based and account for box width
             Y_MAX = 0;

   reg [7:0] x_box; // Left side of box
   reg [6:0] y_box; // top of box

   wire [1:0] x_offset, y_offset;

   assign x_offset = offset_count[1:0];
   assign y_offset = offset_count[3:2];

   reg xdir, ydir; // (1,1) for going right and down

   always @(*) begin
      oColour = ld_black ? 0 : iColour;
      
      oX = x_box + x_offset;
      oY = y_box + y_offset; 
   end

   always @(posedge iClock)
   begin
      if (!iResetn) 
      begin
         offset_count <= 0;
         x_box <= 0;
         y_box <= 0;
         xdir <= 1;
         ydir <= 1;
      end
      else 
      begin
         if (draw_box) offset_count <= offset_count + 1;
         else offset_count <= 0;

         if (update_box) begin
            if (xdir == 1) begin
               if (x_box == X_MAX) begin
                  xdir <= ~xdir;
                  x_box <= x_box - 1;
               end
               else x_box <= x_box + 1;
            end
            else begin
               if (x_box == 0) begin
                  xdir <= ~xdir;
                  x_box <= x_box + 1;
               end
               else x_box <= x_box - 1;
            end

            if (ydir == 1) begin
               if (y_box == Y_MAX) begin
                  ydir <= ~ydir;
                  y_box <= y_box - 1;
               end
               else y_box <= y_box + 1;
            end
            else begin
               if (y_box == 0) begin
                  ydir <= ~ydir;
                  y_box <= y_box + 1;
               end
               else y_box <= y_box - 1;
            end
         end
      end
   end


endmodule


// module datapath(input Resetn, Clock,
//                 input [2:0] Colour,
//                 input [6:0] XY_Coord, 
//                 input ld_x_init, ld_y_init, increment_count, clearing_screen, ld_colour,
//                 input clear_count, ld_x_init_black, ld_y_init_black, ld_colour_black,
//                 output reg [7:0] oX = 0, 
//                 output reg [6:0] oY = 0,
//                 output reg [2:0] oColour = 0,
//                 output reg [14:0] count = 0
//                 );

//    reg [7:0] x_init;
//    reg [6:0] y_init;
   
//    reg [7:0] x_offset;
//    reg [6:0] y_offset;

//    parameter X_SCREEN_PIXELS = 8'd160;
//    parameter Y_SCREEN_PIXELS = 7'd120;

//    always @(*) begin

//       oX = x_init + x_offset;
//       oY = y_init + y_offset; 
//    end

//    always @(posedge Clock)
//    begin

//       if(!Resetn)
//       begin
//          x_init <= 0;
//          y_init <= 0;
//          x_offset <= 0;
//          y_offset <= 0;
//          oColour <= 0;
//          count <= 0;
//       end
//       else begin
//          if (ld_x_init) x_init <= XY_Coord;
//          if (ld_y_init) y_init <= XY_Coord;
//          if (ld_x_init_black) x_init <= 0;
//          if (ld_y_init_black) y_init <= 0;
//          if (ld_colour) oColour <= Colour;
//          if (ld_colour_black) oColour <= 0;
//          if (clear_count) begin
//             count <= 0;
//             x_offset <= 0;
//             y_offset <= 0;
//             x_init <= 0;
//             y_init <= 0;
//          end

//          if (increment_count) begin 
            
//             if (clearing_screen) begin
//                if (x_offset == X_SCREEN_PIXELS-1) begin
//                   if(y_offset != Y_SCREEN_PIXELS-1) begin
//                      x_offset <= 0;
//                      y_offset <= y_offset + 1;
//                      count <= count + 1;
//                   end
//                   else begin
//                      x_offset <= x_offset;
//                      y_offset <= y_offset;
//                      count <= count;
//                   end
//                end
//                else begin
//                   x_offset <= x_offset + 1;
//                   count <= count + 1;
//                end
//             end
//             else begin
//                if (x_offset == 3) begin
//                   if(y_offset != 3) begin
//                      x_offset <= 0;
//                      y_offset <= y_offset + 1;
//                      count <= count + 1;
//                   end
//                   else begin
//                      x_offset <= x_offset;
//                      y_offset <= y_offset;
//                      count <= count;
//                   end
//                end
//                else begin
//                   x_offset <= x_offset + 1;
//                   count <= count + 1;
//                end
//             end

//          end
//       end
//    end
// endmodule