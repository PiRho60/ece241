module RateDivider(clk, Enable, Speed, Reset);
    parameter FREQ = 500;
    parameter FREQ2 = 1000;
    parameter FREQ4 = 2000;
    parameter MAXBITS = 11;

    input Reset;

    input clk;
    reg [MAXBITS-1:0] count;

    input [1:0] Speed;

    output Enable;
    assign Enable = (count == 0) ? 1 : 0;
    
    reg [MAXBITS-1:0] count_max;

    always @(Speed) begin
        if (Speed == 2'b00) count_max = 0;
        else if (Speed == 2'b01) count_max = FREQ-1;
        else if (Speed == 2'b10) count_max = FREQ2-1;
        else begin
            count_max = FREQ4-1;
        end
    end

    initial begin
        if (Speed == 2'b00) count_max = 0;
        else if (Speed == 2'b01) count_max = FREQ-1;
        else if (Speed == 2'b10) count_max = FREQ2-1;
        else begin
            count_max = FREQ4-1;
        end
        count = count_max;
    end


    always @(posedge clk, posedge Reset)
    begin
        if (Reset) count <= count_max;
        else if (Enable) count <= count_max;
        else count <= count - 1;
    end
endmodule

module DisplayCounter(clk, Enable, Reset, q);
    input clk, Enable, Reset;
    output reg [3:0] q;

    initial q = 0;

    always @(posedge clk, posedge Reset)
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

    RateDivider rd0(.clk(ClockIn), .Enable(EnableDC), .Speed(Speed), .Reset(Reset));
    DisplayCounter dc0(.clk(ClockIn), .Enable(EnableDC), .Reset(Reset), .q(CounterValue));
endmodule