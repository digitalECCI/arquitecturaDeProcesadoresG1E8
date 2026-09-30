`include "comparador.v"
`timescale 1s/1s

module final(
    input  [2:0] A_f,
    input  [2:0] B_f,
    output MA_f,
    output MB_f,
    output I_f
);

    // Señales de cada instancia del comparador de 1 bit
    wire I_0, MA_0, MB_0;   // bit 0 (LSB)
    wire I_1, MA_1, MB_1;   // bit 1
    wire I_2, MA_2, MB_2;   // bit 2 (MSB)

    comparador com_1 (
        .A(A_f[2]),
        .B(B_f[2]),
        .I(I_2),
        .MA(MA_2),
        .MB(MB_2)
    );

    comparador com_2 (
        .A(A_f[1]),
        .B(B_f[1]),
        .I(I_1),
        .MA(MA_1),
        .MB(MB_1)
    );

    comparador com_3 (
        .A(A_f[0]),
        .B(B_f[0]),
        .I(I_0),
        .MA(MA_0),
        .MB(MB_0)
    );

    // Señales intermedias de la cascada
    wire i2_i1;      // I2 AND I1
    wire ma_term_a;  // I2 AND MA1
    wire ma_term_b;  // i2_i1 AND MA0
    wire mb_term_a;  // I2 AND MB1
    wire mb_term_b;  // i2_i1 AND MB0

    and u1(i2_i1, I_2, I_1);

    and u2(ma_term_a, I_2, MA_1);
    and u3(ma_term_b, i2_i1, MA_0);
    or  u4(MA_f, MA_2, ma_term_a, ma_term_b);

    and u5(mb_term_a, I_2, MB_1);
    and u6(mb_term_b, i2_i1, MB_0);
    or  u7(MB_f, MB_2, mb_term_a, mb_term_b);

    and u8(I_f, I_2, I_1, I_0);

endmodule