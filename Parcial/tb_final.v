`timescale 1s/1s

module tb_final;

    // Reg para las entradas (generan estímulos)
    reg [2:0] A_f;
    reg [2:0] B_f;

    // Wire para observar las salidas
    wire [2:0] MA_f;
    wire [2:0] MB_f;
    wire [2:0] I_f;

    // Instancia del módulo a probar
    final uut (
        .A_f(A_f),
        .B_f(B_f),
        .MA_f(MA_f),
        .MB_f(MB_f),
        .I_f(I_f)
    );

    initial begin
        // Crear el archivo de ondas para GTKWave
        $dumpfile("ondas.vcd");
        $dumpvars(0, tb_final);

        // Caso 1: Valores iniciales iguales
        A_f = 3'b000; B_f = 3'b000;
        #2;

        // Caso 2: Probar combinaciones mezcladas
        A_f = 3'b101; B_f = 3'b001;
        #2;

        // Caso 3: Invertir valores
        A_f = 3'b010; B_f = 3'b110;
        #2;

        // Caso 4: Todos en 1
        A_f = 3'b111; B_f = 3'b111;
        #2;

        $finish; // Finaliza la simulación
    end

endmodule