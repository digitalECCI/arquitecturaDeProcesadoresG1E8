module double (
    input  [5:0] bin,       // Tu entrada 'pp' de 6 bits
    output reg [3:0] decenas,
    output reg [3:0] unidades
);

    reg [13:0] caja;        // Nuestra caja gigante de 14 espacios

    always @(*) begin
        caja = {4'd0, 4'd0, bin};

        // --- DESPLAZAMIENTO 1 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;       // Revisa las unidades
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3; // Revisa las decenas
        caja = caja << 1;                                    // Corre toda la caja 1 bit a la izquierda

        // --- DESPLAZAMIENTO 2 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3;
        caja = caja << 1;

        // --- DESPLAZAMIENTO 3 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3;
        caja = caja << 1;

        // --- DESPLAZAMIENTO 4 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3;
        caja = caja << 1;

        // --- DESPLAZAMIENTO 5 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3;
        caja = caja << 1;

        // --- DESPLAZAMIENTO 6 ---
        if (caja[9:6] >= 5) caja[9:6] = caja[9:6] + 3;
        if (caja[13:10] >= 5) caja[13:10] = caja[13:10] + 3;
        caja = caja << 1;

        decenas  = caja[13:10];
        unidades = caja[9:6];
    end

endmodule