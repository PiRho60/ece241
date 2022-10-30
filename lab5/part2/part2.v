module RateDivider(clk, Enable, Speed);
    parameter FREQ = 1;
    parameter FREQ2 = 2;
    parameter FREQ4 = 4;
    parameter MAXBITS = 2;


    input clk;
    reg [MAXBITS-1:0] count;

    input [1:0] Speed;

    output Enable;
    assign Enable = (count == 0) ? 1 : 0;
    
    reg [MAXBITS-1:0] count_max;

    always @(*) begin
        if (Speed == 2'b00) count_max = 0;
        else if (Speed == 2'b01) count_max = FREQ-1;
        else if (Speed == 2'b10) count_max = FREQ2-1;
        else begin
            count_max = FREQ4-1;
        end
    end

    initial count = count_max;

    always @(posedge clk)
    begin
        if (Enable)
            count <= count_max;
        else count <= count - 1;
    end
endmodule

module DisplayCounter(clk, Enable, Reset, q);
    input clk, Enable, Reset;
    output reg [3:0] q = 0;

    always @(posedge clk, Reset, Enable)
    begin
        if (Reset) q <= 0;
        else if (Enable) q <= q + 1;
        else q <= q;
    end
endmodule


module part2(ClockIn, Reset, Speed, CounterValue);
    input ClockIn, Reset;
    input [1:0] Speed;
    output [3:0] CounterValue;

    wire EnableDC;

    RateDivider rd0(.clk(ClockIn), .Enable(EnableDC), .Speed(Speed));
    DisplayCounter dc0(.clk(ClockIn), .Enable(EnableDC), .Reset(Reset), .q(CounterValue));
endmodule