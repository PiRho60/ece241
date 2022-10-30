module mux_2to1(x, y, s, f);
    input x, y, s;
    output f;
    
    assign f = s ? y : x;
endmodule

module flipflop(clock, reset, D, Q);
    input clock, reset, D;
    output reg Q;

    always @(posedge clock, posedge reset)
    begin
        if(reset)
            Q <= 0;
        else
            Q <= D;
    end
endmodule

module sreg_1bit(left, right, LoadLeft, D, loadn, clock, reset, Q);
    input left, right, LoadLeft, D, loadn, clock, reset;
    output Q;

    wire w0, w1;

    mux_2to1 m0(.x(right), .y(left), .s(LoadLeft), .f(w0));
    mux_2to1 m1(.x(D), .y(w0), .s(loadn), .f(w1));

    flipflop ff0(.D(w1), .clock(clock), .reset(reset), .Q(Q));
endmodule

module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
    input clock, reset, ParallelLoadn, RotateRight, ASRight;
    input [7:0] Data_IN;
    output reg [7:0] Q;

    wire [7:0] Q_rot; // rotated Q

    // assign Q_rot[7] = ASRight ? Q[7] : Q[0];

    
    sreg_1bit s7(.left(Q[0]), .right(Q[6]), .LoadLeft(RotateRight), 
        .D(Data_IN[7]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[7]));
    sreg_1bit s0(.left(Q[7]), .right(Q[5]), .LoadLeft(RotateRight), 
        .D(Data_IN[6]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[6]));
    sreg_1bit s1(.left(Q[6]), .right(Q[4]), .LoadLeft(RotateRight), 
        .D(Data_IN[5]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[5])); 
    sreg_1bit s2(.left(Q[5]), .right(Q[3]), .LoadLeft(RotateRight), 
        .D(Data_IN[4]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[4]));
    sreg_1bit s3(.left(Q[4]), .right(Q[2]), .LoadLeft(RotateRight), 
        .D(Data_IN[3]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[3]));
    sreg_1bit s4(.left(Q[3]), .right(Q[1]), .LoadLeft(RotateRight), 
        .D(Data_IN[2]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[2]));
    sreg_1bit s5(.left(Q[2]), .right(Q[0]), .LoadLeft(RotateRight), 
        .D(Data_IN[1]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[1]));
    sreg_1bit s6(.left(Q[1]), .right(Q[7]), .LoadLeft(RotateRight), 
        .D(Data_IN[0]), .loadn(ParallelLoadn), .clock(clock), 
        .reset(reset), .Q(Q_rot[0]));

    // assign Q = Q_rot;


    always @(*)
    begin
        if (ParallelLoadn && RotateRight && ASRight) begin
            Q[6:0] = Q_rot[6:0]; // Keep Q[7] same.
        end else begin
            Q = Q_rot;
        end
    end
    // always @(posedge clock)
    // begin
    //     if (reset)
    //         Q <= 8'h00;
    //     else if(!ParallelLoadn)
    //         Q <= Data_IN;
    //     else
    //         if (RotateRight)
    //             if (ASRight)
    //                 Q[6:0] <= Q_rot[6:0];
    //             else
    //                 Q <= Q_rot;
    //         else
    //             Q <= Q_rot;

    // end
endmodule

// module rotreg_8bit(SW, KEY, LEDR);
//     input [9:0] SW;
//     input [3:0] KEY;
//     output [7:0] LEDR;

//     part3 p(.clock(KEY[0]), .reset(SW[9]), .ParallelLoadn(KEY[1]), 
//         .RotateRight(KEY[2]), .ASRight(KEY[3]), 
//         .Data_IN(SW[7:0]), .Q(LEDR[7:0]));
// endmodule