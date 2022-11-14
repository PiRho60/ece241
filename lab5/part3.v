module part3(ClockIn, Resetn, Start, Letter,
        DotDashOut, NewBitOut);
    input ClockIn, Resetn, Start;
    input [2:0] Letter;
    output NewBitOut, DotDashOut;

    RateDivider rd0(.clk(ClockIn), .Enable(NewBitOut),
        .Resetn(Resetn), .Start(Start));

    wire [11-1:0] morse;
    lut l0(.letter(Letter), .morse(morse));

    sreg sr0(.clk(ClockIn), .shift(NewBitOut), .load(Start), .D(morse), .q(DotDashOut), .resetn(Resetn));
endmodule


module RateDivider(clk, Enable, Resetn, Start);
    parameter FREQdiv2 = 250;
    parameter MAXBITS = 8;
    parameter TOTAL_BITS = 11+1;

    reg [3:0] bits_to_send;
    input Start;

    input Resetn;

    input clk;
    reg [MAXBITS-1:0] count;

    output Enable;
    assign Enable = (count == 0) ? 1 : 0;
    
    reg [MAXBITS-1:0] count_max;

    initial begin
        count_max = FREQdiv2-1;
        count = count_max;
        bits_to_send = TOTAL_BITS;
    end


    always @(posedge clk, negedge Resetn)
    begin
        if (!Resetn) count <= count_max;
        else if (Start) 
        begin
            count <= count_max;
            bits_to_send <= TOTAL_BITS;
        end
        else if (bits_to_send == 0)
        begin
            count <= count_max;
        end
        else if (Enable) // count == 0.
        begin 
            count <= count_max;
            bits_to_send <= bits_to_send - 1;
        end 
        else count <= count - 1;
    end
endmodule




module lut(letter, morse);

    input [2:0] letter;
    output reg [11-1:0] morse;


    always @(*)
    begin
        case (letter)
            3'b000: morse = 11'b10111000000;
            3'b001: morse = 11'b11101010100;
            3'b010: morse = 11'b11101011101;
            3'b011: morse = 11'b11101010000;
            3'b100: morse = 11'b10000000000;
            3'b101: morse = 11'b10101110100;
            3'b110: morse = 11'b11101110100;
            3'b111: morse = 11'b10101010000;
        endcase
    end


endmodule


module sreg(clk, shift, load, D, q, resetn);
    parameter TOTAL_BITS = 11;

    input clk;
    input resetn;
    input shift, load;
    input [TOTAL_BITS-1:0] D; // Need 11 bits for morse code letters.
    output q;
    reg [TOTAL_BITS-1:0] morse;

    assign q = morse[TOTAL_BITS-1];


    always @(posedge clk, negedge resetn)
    begin
        if (!resetn) morse <= 0;
        else if (load) morse <= D;
        else if (shift) morse <= morse << 1;
        else morse <= morse;
    end



endmodule