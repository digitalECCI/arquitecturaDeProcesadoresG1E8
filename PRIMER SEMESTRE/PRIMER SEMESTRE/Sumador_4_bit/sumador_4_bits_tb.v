`include "sumador_4_bits.v"
`timescale 1s/1s

module sumadorTB();

reg  [3:0] A_tb;
reg  [3:0] B_tb;
reg  Ci_tb;
wire [3:0] S_tb;
wire Co_tb;



integer i, j, k;



sumador_4 uut(
    .A_su  (A_tb),
    .B_su  (B_tb),
    .Ci_su (Ci_tb),
    .S_su  (S_tb),
    .Co_su (Co_tb)
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
                Ci_tb = k;

                #5; 
            end
        end
    end

    $finish;
end

endmodule