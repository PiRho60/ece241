module part2(Clock, Reset_b, Data, Function, ALUout);
    input [3:0] Data;
    input Clock, Reset_b;
    input [2:0] Function;
    output reg [7:0] ALUout;

    wire [4:0] adder_out;
    wire [3:0] w0;
    adder a0(.a(Data), .b(ALUout[3:0]), .c_in(1'b0), .c_out(w0), .s(adder_out[3:0]));
    assign adder_out[4] = w0[3];

    always @(posedge Clock) begin
        if (Reset_b == 1'b0)
            ALUout <= 8'h00;
        else

            case (Function)
                3'b000: ALUout <= {3'b0, adder_out};
                3'b001: ALUout <= {Data + ALUout[3:0]};
                3'b010: ALUout <= {{4{ALUout[3]}}, ALUout[3:0]};
                3'b011: ALUout <= {7'b0, |{Data, ALUout[3:0]}};
                3'b100: ALUout <= {7'b0, &{Data, ALUout[3:0]}};
                3'b101: ALUout <= {4'b0, ALUout[3:0]} << Data;
                3'b110: ALUout <= Data*ALUout[3:0];
                3'b111: ;
                // default: ALUout <= 8'h00;
            endcase
    end
endmodule

// module alu(SW, KEY, LEDR, HEX0, HEX2, HEX4, HEX5);
//     input [7:0] SW;
//     input [2:0] KEY;
//     output [7:0] LEDR;
//     output HEX0, HEX2, HEX4, HEX5;

//     wire [7:0] ALUout_wire;

//     part2 a0(.Data(SW[3:0]), .Clock(KEY[0]), .Reset_b(SW[9]), .Function(KEY[3:1]), .ALUout(ALUout_wire), .Function(~KEY[2:0]), .ALUout(ALUout_wire));

//     assign LEDR[7:0] = ALUout_wire[7:0];

//     hex_decoder(.c(ALUout_wire[3:0]), .display(HEX4));
//     hex_decoder(.c(ALUout_wire[7:4]), .display(HEX5));

//     hex_decoder(.c(SW[3:0]), .display(HEX0)); // A
// endmodule

















module full_adder(a, b, c_in, s, c_out);
    input a, b, c_in;
    output s, c_out;

    assign {c_out, s} = a + b + c_in;
endmodule

module adder(a, b, c_in, s, c_out);
    input [3:0] a, b;
    input c_in;
    output [3:0] s, c_out;

    full_adder f0(.a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(c_out[0]));
    full_adder f1(.a(a[1]), .b(b[1]), .c_in(c_out[0]), .s(s[1]), .c_out(c_out[1]));
    full_adder f2(.a(a[2]), .b(b[2]), .c_in(c_out[1]), .s(s[2]), .c_out(c_out[2]));
    full_adder f3(.a(a[3]), .b(b[3]), .c_in(c_out[2]), .s(s[3]), .c_out(c_out[3]));
endmodule

module adder_top(SW, LEDR);
    input [9:0] SW;
    output [9:0] LEDR;

    wire [3:0] w1;

    part2 a0(.a(SW[7:4]), .b(SW[3:0]), .c_in(SW[8]), .c_out(w1), .s(LEDR[3:0]));

    assign LEDR[9] = w1[3];
endmodule



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