`include "conta4bits.v"
`timescale 1s/1s

module sumadorTB();

reg  [3:0] A_tb;
reg  [3:0] B_tb;
reg  [3:0] Ci_tb;
wire [3:0] S_tb;
wire C0_tb;
wire C1_tb;
wire C2_tb;
wire C3_tb;



initial begin
    A_tb  = 1'b0;
    B_tb  = 1'b0;
    Ci_tb = 1'b0;
end

initial begin
    //Caso 1
    A_tb  = 1'b0;
    B_tb = 1'b0;
    Ci_tb = 1'b0;
    #5;
    A_tb  = 1'b0;
    B_tb  = 1'b0;
    Ci_tb = 1'b1;
    #5;
    A_tb  = 1'b0;
    B_tb  = 1'b1;
    Ci_tb = 1'b0;
    #5;
    A_tb  = 1'b0;
    B_tb  = 1'b1;
    Ci_tb = 1'b1;
    #5;
    A_tb  = 1'b1;
    B_tb  = 1'b0;
    Ci_tb = 1'b0;
end


initial begin:TEST_CASE
    $dumpfile("simulacion_tb.vcd");
    $dumpvars(-1,uut);
    #40;
end


endmodule