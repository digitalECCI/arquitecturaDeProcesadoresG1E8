module uart (
    input wire clk,          // Reloj de 50 MHz
    input wire rst_n,        // Reset activo en bajo (KEY[1])
    input wire [7:0] data_in,// Datos de los interruptores (SW[7:0])
    output reg tx,           // Salida UART hacia CP2102 RXD
    output reg busy          // Indicador de estado
);

    parameter CLKS_PER_BIT = 5208; // 50MHz / 9600 baudios

    // Contador de pausa entre envíos (aprox. 0.5 segundos a 50MHz)
    reg [24:0] delay_counter = 0;
    localparam DELAY_LIMIT = 25_000_000;

    // Máquina de estados UART
    localparam state_idle  = 3'b000;
    localparam state_delay = 3'b001;
    localparam state_start = 3'b010;
    localparam state_data  = 3'b011;
    localparam state_stop  = 3'b100;

    reg [2:0] state = state_idle;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] shadow_data = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= state_idle;
            tx <= 1'b1;
            busy <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
            delay_counter <= 0;
        end else begin
            case (state)
                state_idle: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    shadow_data <= data_in;
                    state <= state_delay;
                    delay_counter <= 0;
                end

                state_delay: begin
                    busy <= 1'b0;
                    tx <= 1'b1;
                    if (delay_counter < DELAY_LIMIT - 1) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        delay_counter <= 0;
                        shadow_data <= data_in; // Captura el estado actual de los switches
                        state <= state_start;
                        busy <= 1'b1;
                        clk_count <= 0;
                    end
                end

                state_start: begin
                    tx <= 1'b0; // Bit de inicio
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= state_data;
                        bit_index <= 0;
                    end
                end

                state_data: begin
                    tx <= shadow_data[bit_index]; // Bit de datos (LSB primero)
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= state_stop;
                        end
                    end
                end

                state_stop: begin
                    tx <= 1'b1; // Bit de parada
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= state_delay; // Regresa al estado de espera para repetir
                    end
                end

                default: state <= state_idle;
            endcase
        end
    end
endmodule