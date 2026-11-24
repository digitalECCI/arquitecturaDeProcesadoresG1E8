module uart (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    output reg tx,
    output reg busy
);

    parameter CLKS_PER_BIT = 5208; // 50MHz / 9600 baudios

    reg [24:0] delay_counter = 0;
    localparam DELAY_LIMIT = 25_000_000;

    localparam state_idle  = 3'b000;
    localparam state_delay = 3'b001;
    localparam state_start = 3'b010;
    localparam state_data  = 3'b011;
    localparam state_stop  = 3'b100;

    reg [2:0]  state = state_idle;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  shadow_data = 0;
    reg [3:0]  char_index = 0;   // 0-7: bits, 8: '\r', 9: '\n'

    // Carácter ASCII que toca enviar según la posición del mensaje
    reg [7:0] tx_byte;
    always @(*) begin
        if (char_index < 4'd8)
            tx_byte = shadow_data[3'd7 - char_index[2:0]] ? 8'h31 : 8'h30; // '1' o '0'
        else if (char_index == 4'd8)
            tx_byte = 8'h0D; // retorno de carro
        else
            tx_byte = 8'h0A; // salto de línea
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= state_idle;
            tx <= 1'b1;
            busy <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
            char_index <= 0;
            delay_counter <= 0;
        end else begin
            case (state)
                state_idle: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
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
                        shadow_data <= data_in;   // se congela durante todo el mensaje
                        char_index <= 0;
                        state <= state_start;
                        busy <= 1'b1;
                        clk_count <= 0;
                    end
                end

                state_start: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= state_data;
                        bit_index <= 0;
                    end
                end

                state_data: begin
                    tx <= tx_byte[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else               state <= state_stop;
                    end
                end

                state_stop: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (char_index < 4'd9) begin
                            char_index <= char_index + 1;  // siguiente carácter
                            state <= state_start;
                        end else begin
                            char_index <= 0;               // mensaje completo
                            state <= state_delay;
                        end
                    end
                end

                default: state <= state_idle;
            endcase
        end
    end
endmodule