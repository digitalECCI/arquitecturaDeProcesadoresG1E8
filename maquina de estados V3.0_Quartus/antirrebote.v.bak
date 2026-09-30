module antirrebote (
    input clk,
    input boton_in,
    output reg boton_out
);
    reg [2:0] contador = 0;
    reg estado_actual = 1'b0;

    // Inicialización explícita para evitar líneas rojas (X) en simulación
    initial begin
        boton_out = 1'b0;
    end

    always @(posedge clk) begin
        if (boton_in != estado_actual) begin
            contador <= contador + 1'b1;
            if (contador == 3'b111) begin
                estado_actual <= boton_in;
                boton_out     <= boton_in;
                contador      <= 0;
            end
        end else begin
            contador <= 0;
        end
    end
endmodule