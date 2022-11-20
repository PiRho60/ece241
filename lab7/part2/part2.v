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
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame

   //
   // Your code goes here
   wire ld_x, ld_y, increment_count, clearing_screen;
   wire [3:0] offset_count;
   control c0(.Resetn(iResetn), .PlotBox(iPlotBox), .Black(iBlack), 
              .Clock(iClock), .LoadX(iLoadX), .offset_count(offset_count),
              .Done(oDone), .ld_x(ld_x), .ld_y(ld_y),
              .increment_count(increment_count),
              .clearing_screen(clearing_screen),
              .Plot(oPlot)
              );

   datapath d0(.Resetn(iResetn), .Clock(iClock),
               .Colour(iColour), .XY_Coord(iXY_Coord), 
               .ld_x(ld_x), .ld_y(ld_y), .increment_count(increment_count),
               .clearing_screen(clearing_screen), .oX(oX), .oY(oY),
               .oColour(oColour),
               .offset_count(offset_count)
               );
   //

endmodule // part2

module control(input Resetn, PlotBox, Black, Clock, LoadX, 
               input [3:0] offset_count,
               output reg Done = 0,
               output reg ld_x = 0, ld_y = 0, increment_count = 0, 
               output reg Plot = 0, clearing_screen = 0
               );

   reg [2:0] current_state, next_state;

   localparam S_LOAD_X = 0,
              S_LOAD_X_WAIT = 1,
              S_LOAD_Y = 2,
              S_LOAD_Y_WAIT = 3,
              S_DRAW = 4;

   always @(posedge Clock)
   begin
      if (!Resetn) begin
         Done <= 0;
         clearing_screen <= 0;
      end
      else begin
         if (offset_count == 4'b1111) Done <= 1;
         else if (current_state == S_DRAW) Done <= 0;
         clearing_screen = Black ? 1 : (clearing_screen && !Done);
      end
   end

   always @(posedge Clock)
   begin: state_table
      case (current_state)
         S_LOAD_X: next_state = LoadX ? S_LOAD_X_WAIT : S_LOAD_X;
         S_LOAD_X_WAIT: next_state = LoadX ? S_LOAD_X_WAIT : S_LOAD_Y;
         S_LOAD_Y: next_state = PlotBox ? S_LOAD_Y_WAIT : S_LOAD_Y;
         S_LOAD_Y_WAIT: next_state = PlotBox ? S_LOAD_Y_WAIT : S_DRAW;
         S_DRAW: next_state = (offset_count == 4'b1111) ? S_LOAD_X : S_DRAW;
      endcase
   end

   always @(*)
   begin: enable_signals

      ld_x = 0;
      ld_y = 0;
      increment_count = 0;
      Plot = 0;
      
      case (current_state)
         S_LOAD_X:
            ld_x = 1;
         S_LOAD_Y:
            ld_y = 1;
         S_DRAW: begin
            increment_count = 1;
            Plot = 1;
         end
      endcase
   end

   always @(posedge Clock)
   begin: state_FFs
      if (!Resetn) current_state <= S_LOAD_X;
      else if (Black) current_state <= S_LOAD_X;  
      else current_state <= next_state;
   end


endmodule

module datapath(input Resetn, Clock,
                input [2:0] Colour,
                input [6:0] XY_Coord, 
                input ld_x, ld_y, increment_count, clearing_screen,
                output reg [7:0] oX = 0, 
                output reg [6:0] oY = 0,
                output reg [2:0] oColour = 0,
                output reg [3:0] offset_count = 0
                );

   reg [7:0] x_pos;
   reg [6:0] y_pos;
   
   reg [1:0] x_offset;
   reg [1:0] y_offset;

   always @(*) begin
      x_offset = offset_count[1:0];
      y_offset = offset_count[3:2];
      oX = x_pos + x_offset;
      oY = y_pos + y_offset; 
   end

   always @(posedge Clock)
   begin
      if(!Resetn)
      begin
         x_pos <= 0;
         y_pos <= 0;
         oColour <= 0;
         offset_count <= 0;
      end
      else begin
         if (ld_x) x_pos <= XY_Coord;
         if (ld_y) y_pos <= XY_Coord;
         if (increment_count) offset_count <= offset_count + 1;
         else offset_count <= 0;
         oColour <= clearing_screen ? 0 : Colour;
      end
   end

endmodule
