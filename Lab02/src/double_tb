`include "double.v"
`timescale 1s/1s

module double_TB();

reg  [3:0] A_tb;
reg  [3:0] B_tb;
reg  sel_tb;
wire  [3:0] uni_tb;
wire  [3:0] des_tb;
wire [3:0] S_tb;
wire Co_tb;
wire [6:0] uni_seg_tb;
wire [6:0] des_seg_tb;


integer i, j, k;



double uut(
    .A_do   (A_tb),
    .B_do   (B_tb),
    .sel_do (sel_tb),
    .So_do  (S_tb),
    .Co_do  (Co_tb),
    .uni    (uni_tb),
    .des    (des_tb),
    .uni_seg (uni_seg_tb),
    .des_seg (des_seg_tb)
);




initial begin: TEST_CASE
    // Archivos para la simulación
    $dumpfile("simulacion_tb.vcd");
    $dumpvars(-1, uut);

    for (i = 0; i < 16; i = i + 1) begin        // A de 0 a 15
        for (j = 0; j < 16; j = j + 1) begin    // B de 0 a 15
            for (k = 0; k < 2; k = k + 1) begin // Ci de 0 a 1

                A_tb  = i;
                B_tb  = j;
                sel_tb = k;

                #5; 
            end
        end
    end

    $finish;
end

endmodule
