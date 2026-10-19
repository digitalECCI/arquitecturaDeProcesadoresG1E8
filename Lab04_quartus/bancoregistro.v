module banco_registros (
    input  wire       clk,         
    input  wire       rst_btn,   // Entrada del botón físico con rebote (activo en bajo)
    input  wire [7:0] data_in,     
    input  wire [2:0] addr,
    input  wire       write_en,
    input  wire       read_en,
    output reg  [7:0] data_out
);

    
    reg [15:0] contador_rebote = 0; 
    reg btn_sync_1 = 1'b1;
    reg btn_sync_2 = 1'b1;
    reg rst_limpio = 1'b1;

    // 1. Sincronización para evitar metaestabilidad
    always @(posedge clk) begin
        btn_sync_1 <= rst_btn;
        btn_sync_2 <= btn_sync_1;
    end

    // 2. Contador de estabilización
    always @(posedge clk) begin
        if (btn_sync_2 == rst_limpio) begin
            contador_rebote <= 0; // Si no hay cambios, reiniciar contador
        end else begin
            contador_rebote <= contador_rebote + 1;
            // Cuando el contador alcanza el máximo, aceptamos el nuevo estado
            if (contador_rebote == 16'hFFFF) begin 
                rst_limpio <= btn_sync_2;
                contador_rebote <= 0;
            end
        end
    end

    reg [7:0] registros [0:7];

  
    always @(posedge clk) begin
        if (!rst_limpio) begin
            registros[0] <= 8'b0;
            registros[1] <= 8'b0;
            registros[2] <= 8'b0;
            registros[3] <= 8'b0;
            registros[4] <= 8'b0;
            registros[5] <= 8'b0;
            registros[6] <= 8'b0;
            registros[7] <= 8'b0;
            data_out     <= 8'b0;
        end
        else begin
            // Escritura
            if (write_en) begin
                case (addr)
                    3'b000: registros[0] <= data_in;
                    3'b001: registros[1] <= data_in;
                    3'b010: registros[2] <= data_in;
                    3'b011: registros[3] <= data_in;
                    3'b100: registros[4] <= data_in;
                    3'b101: registros[5] <= data_in;
                    3'b110: registros[6] <= data_in;
                    3'b111: registros[7] <= data_in;
                    default: ;
                endcase
            end

            // Lectura
            if (read_en) begin
                case (addr)
                    3'b000: data_out <= registros[0];
                    3'b001: data_out <= registros[1];
                    3'b010: data_out <= registros[2];
                    3'b011: data_out <= registros[3];
                    3'b100: data_out <= registros[4];
                    3'b101: data_out <= registros[5];
                    3'b110: data_out <= registros[6];
                    3'b111: data_out <= registros[7];
                    default: data_out <= 8'b0;
                endcase
            end
        end
    end
endmodule