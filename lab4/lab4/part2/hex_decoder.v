

module hex_decoder(input [3:0] c, output reg [6:0] display);
	 
	 always @(c) begin
        case(c)
            4'b0000: display = 7'b0000001; // 7-segment code for 0
            4'b0001: display = 7'b1001111; // 7-segment code for 1
            4'b0010: display = 7'b0010010; // 7-segment code for 2
            4'b0011: display = 7'b0000110; // 7-segment code for 3
            4'b0100: display = 7'b1001100; // 7-segment code for 4
            4'b0101: display = 7'b0100100; // 7-segment code for 5
            4'b0110: display = 7'b0100000; // 7-segment code for 6
            4'b0111: display = 7'b0001111; // 7-segment code for 7
            4'b1000: display = 7'b0000000; // 7-segment code for 8
            4'b1001: display = 7'b0000100; // 7-segment code for 9
            4'b1010: display = 7'b0001000; // 7-segment code for A
            4'b1011: display = 7'b1100000; // 7-segment code for B
            4'b1100: display = 7'b0110001; // 7-segment code for C
            4'b1101: display = 7'b1000010; // 7-segment code for D
            4'b1110: display = 7'b0110000; // 7-segment code for E
            4'b1111: display = 7'b0111000; // 7-segment code for F
            default: display = 7'b1111111; // Default Case
        endcase
    end
endmodule















