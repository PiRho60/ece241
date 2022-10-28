
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