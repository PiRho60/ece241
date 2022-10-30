module part1(Clock, Enable, Clear_b, CounterValue);
    input Clock, Enable, Clear_b;
    output [7:0] CounterValue;

    wire [7:0] w;
    assign w[0] = Enable;
    assign w[1] = w[0] & CounterValue[0];
    assign w[2] = w[1] & CounterValue[1];
    assign w[3] = w[2] & CounterValue[2];
    assign w[4] = w[3] & CounterValue[3];
    assign w[5] = w[4] & CounterValue[4];
    assign w[6] = w[5] & CounterValue[5];
    assign w[7] = w[6] & CounterValue[6];

    T_FF t0(.T(w[0]), .Q(CounterValue[0]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t1(.T(w[1]), .Q(CounterValue[1]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t2(.T(w[2]), .Q(CounterValue[2]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t3(.T(w[3]), .Q(CounterValue[3]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t4(.T(w[4]), .Q(CounterValue[4]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t5(.T(w[5]), .Q(CounterValue[5]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t6(.T(w[6]), .Q(CounterValue[6]), .Clock(Clock), .Clear_b(Clear_b));
    T_FF t7(.T(w[7]), .Q(CounterValue[7]), .Clock(Clock), .Clear_b(Clear_b));
endmodule


// module part1(Clock, Enable, Clear_b, CounterValue);
//     input Clock, Enable, Clear_b;
//     output reg [7:0] CounterValue = 8'b00000000;
//     always @(posedge Clock, Clear_b)
//     begin
//         if (!Clear_b) CounterValue = 0;
//         else if (Enable) CounterValue <= CounterValue + 1;
//         else CounterValue <= CounterValue;
//     end
// endmodule



module T_FF(T, Q, Clock, Clear_b);
    input T, Clock, Clear_b;
    output reg Q;

    always @(posedge Clock, negedge Clear_b)
    begin
        if (!Clear_b) Q <= 0;
        else if (T) Q <= ~Q;
        else Q <= Q;
    end
endmodule