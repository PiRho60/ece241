//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   assign oX[7] = 0;
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame

   //
   // Your code goes here
   wire ld_x_init, ld_y_init, increment_count, clearing_screen, ld_colour, clear_count, ld_x_init_black, ld_y_init_black, ld_colour_black;
   wire [3:0] count;
   control #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) c0(.Resetn(iResetn), .PlotBox(iPlotBox), .Black(iBlack), 
              .Clock(iClock), .LoadX(iLoadX), .count(count),
              .Done(oDone), .ld_x_init(ld_x_init), .ld_y_init(ld_y_init),
              .increment_count(increment_count),
              .clearing_screen(clearing_screen),
              .Plot(oPlot),
              .ld_colour(ld_colour),
              .clear_count(clear_count),
              .ld_x_init_black(ld_x_init_black),
              .ld_y_init_black(ld_y_init_black),
              .ld_colour_black(ld_colour_black)
              );

   datapath #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) d0(.Resetn(iResetn), .Clock(iClock),
               .Colour(iColour), .XY_Coord(iXY_Coord), 
               .ld_x_init(ld_x_init), .ld_y_init(ld_y_init), .increment_count(increment_count),
               .clearing_screen(clearing_screen), .oX(oX), .oY(oY),
               .oColour(oColour),
               .count(count),
               .ld_colour(ld_colour),
               .clear_count(clear_count),
              .ld_x_init_black(ld_x_init_black),
              .ld_y_init_black(ld_y_init_black),
              .ld_colour_black(ld_colour_black)
               );
   //

endmodule // part2

module control(input Resetn, PlotBox, Black, Clock, LoadX, 
               input [3:0] count,
               output reg Done = 0,
               output reg ld_x_init = 0, ld_y_init = 0, ld_colour = 0, increment_count = 0, 
               output reg ld_x_init_black = 0, ld_y_init_black = 0, ld_colour_black = 0,
               output reg Plot = 0, clearing_screen = 0, clear_count = 0
               );

   reg [2:0] current_state, next_state;

   localparam S_LOAD_X = 0,
              S_LOAD_X_WAIT = 1,
              S_LOAD_Y = 2,
              S_LOAD_Y_WAIT = 3,
              S_DRAW = 4,
              S_LOAD_BLACK_WAIT = 5,
              S_DRAW_BLACK = 6,
              S_DONE = 7;

   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   always @(*)
   begin: state_table
      case (current_state)
         S_LOAD_X: next_state = LoadX ? S_LOAD_X_WAIT : S_LOAD_X;
         S_LOAD_X_WAIT: next_state = LoadX ? S_LOAD_X_WAIT : S_LOAD_Y;
         S_LOAD_Y: next_state = PlotBox ? S_LOAD_Y_WAIT : S_LOAD_Y;
         S_LOAD_Y_WAIT: next_state = PlotBox ? S_LOAD_Y_WAIT : S_DRAW;
         S_DRAW: next_state = (count == 4'b1111) ? S_DONE : S_DRAW;
         S_LOAD_BLACK_WAIT: next_state = Black ? S_LOAD_BLACK_WAIT : S_DRAW_BLACK;
         S_DRAW_BLACK: next_state = (count == X_SCREEN_PIXELS*Y_SCREEN_PIXELS - 1) ? S_DONE : S_DRAW_BLACK;
         S_DONE: next_state = S_LOAD_X;
      endcase
   end

   always @(*)
   begin: enable_signals

   if (!Resetn) Done = 0;

      clear_count = 0;
      ld_x_init = 0;
      ld_y_init = 0;
      ld_x_init_black = 0;
      ld_y_init_black = 0;
      ld_colour = 0;
      ld_colour_black = 0;
      increment_count = 0;
      Plot = 0;
      
      case (current_state)
         S_LOAD_X:
            clear_count = 1;
         S_LOAD_X_WAIT:
            ld_x_init = 1;
         // S_LOAD_Y:
         //    ld_y_init = 1;
         S_LOAD_Y_WAIT:begin
            ld_y_init = 1;
            ld_colour = 1;
         end
         S_DRAW: begin
            Done = 0;
            increment_count = 1;
            Plot = 1;
         end
         S_LOAD_BLACK_WAIT: begin
            Done = 0;
            clear_count = 1;
            ld_colour_black = 1; 
            ld_x_init_black = 1;
            ld_y_init_black = 1;   
         end
         S_DRAW_BLACK: begin
            increment_count = 1;
            Plot = 1;
            clearing_screen = 1;
         end
         S_DONE: begin
            Done = 1;
         end
      endcase
   end

   always @(posedge Clock)
   begin: state_FFs
      if (!Resetn) current_state <= S_LOAD_X;
      else if (Black) current_state <= S_LOAD_BLACK_WAIT;  
      else current_state <= next_state;
   end


endmodule

module datapath(input Resetn, Clock,
                input [2:0] Colour,
                input [6:0] XY_Coord, 
                input ld_x_init, ld_y_init, increment_count, clearing_screen, ld_colour,
                input clear_count, ld_x_init_black, ld_y_init_black, ld_colour_black,
                output reg [7:0] oX = 0, 
                output reg [6:0] oY = 0,
                output reg [2:0] oColour = 0,
                output reg [14:0] count = 0
                );

   reg [7:0] x_init;
   reg [6:0] y_init;
   
   reg [7:0] x_offset;
   reg [6:0] y_offset;

   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   always @(*) begin
      if (clearing_screen) begin
         x_init = 0;
         y_init = 0;
      end

      oX = x_init + x_offset;
      oY = y_init + y_offset; 
   end

   always @(posedge Clock)
   begin

      if(!Resetn)
      begin
         x_init <= 0;
         y_init <= 0;
         x_offset <= 0;
         y_offset <= 0;
         oColour <= 0;
         count <= 0;
      end
      else begin
         if (ld_x_init) x_init <= XY_Coord;
         if (ld_y_init) y_init <= XY_Coord;
         if (ld_x_init_black) x_init <= 0;
         if (ld_y_init_black) y_init <= 0;
         if (ld_colour) oColour <= Colour;
         if (ld_colour_black) oColour <= 0;

         if (increment_count) begin 
            count <= count + 1;
            x_offset <= x_offset + 1;
         end

         if (clearing_screen) begin
            if (x_offset == X_SCREEN_PIXELS-1) begin
               if(y_offset != Y_SCREEN_PIXELS-1) begin
                  x_offset <= 0;
                  y_offset <= y_offset + 1;
               end
               else begin
                  x_offset <= x_offset;
                  y_offset <= y_offset;
               end
            end
         end
         else begin
            if (x_offset == 3) begin
               if(y_offset != 3) begin
                  x_offset <= 0;
                  y_offset <= y_offset + 1;
               end
               else begin
                  x_offset <= x_offset;
                  y_offset <= y_offset;
               end
            end
         end
      end
   end
endmodule

