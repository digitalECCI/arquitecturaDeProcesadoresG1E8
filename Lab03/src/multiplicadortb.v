`include "multiplicador.v"
`timescale 1s/1s

module multiplicador_tb();
    reg        clk_tb;
    reg        rst_tb;     
    reg        init_tb;    
    reg  [2:0] md_tb;      
    reg  [2:0] mr_tb;      
    wire [5:0] pp_tb;  
    wire       done_tb;
    wire [6:0] display_uni_tb;
    wire [6:0] display_des_tb;

    // Instancia del Top Level
    multiplicador uut (
        .clk         (clk_tb),
        .rst         (rst_tb),
        .init        (init_tb),
        .md          (md_tb),
        .mr          (mr_tb),
        .pp          (pp_tb),
        .done        (done_tb),
        .display_uni (display_uni_tb),
        .display_des (display_des_tb)
    );

    integer i, j;

    // Generador de Reloj
    always #1 clk_tb = ~clk_tb; 

    initial begin
        $dumpfile("simulacion_tb.vcd");
        $dumpvars(-1, uut);

        // Estado inicial
        clk_tb  = 0;
        rst_tb  = 0;
        init_tb = 0;
        mr_tb   = 0;
        md_tb   = 0;

        #2;
        // Pulso rápido de Reset (1 ciclo)
        rst_tb = 1;
        #2;
        rst_tb = 0;
        #2;

        // Bucle para probar de 0x0 a 7x7
        for (i = 0; i < 8; i = i + 1) begin        
            for (j = 0; j < 8; j = j + 1) begin    

                mr_tb = i;
                md_tb = j;

                // Pulso de inicio directo de 1 ciclo
                @(posedge clk_tb);
                init_tb = 1;
                @(posedge clk_tb);
                init_tb = 0; 

                // Esperar a que finalice la multiplicación
                wait(done_tb == 1'b1);
                @(posedge clk_tb);

                if (pp_tb !== (i * j)) begin
                    $display("[ERROR] %d x %d = %d | Esperado: %d", i, j, pp_tb, (i * j));
                end else begin
                    $display("[OK]    %d x %d = %d", i, j, pp_tb);
                end
            end
        end

        #10;
        $display("--- SIMULACION FINALIZADA EXITOSAMENTE ---");
        $finish;
    end

endmodule