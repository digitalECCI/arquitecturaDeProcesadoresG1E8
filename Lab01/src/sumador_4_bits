`include "sumador1b.v"
`timescale 1s/1s

module sumador_4(
    input  [3:0] A_su,
    input  [3:0] B_su,
    input  Ci_su,
    output [3:0] S_su,
    output Co_su
);

wire c1;
wire c2;
wire c3;


sumador1b sum_1(
    .A(A_su[0]),
    .B(B_su[0]),
    .Ci(Ci_su),
    .S(S_su[0]),
    .Co(c1)
);


sumador1b sum_2(
    .A(A_su[1]),
    .B(B_su[1]),
    .Ci(c1),
    .S(S_su[1]),
    .Co(c2)
);


sumador1b sum_3(
    .A(A_su[2]),
    .B(B_su[2]),
    .Ci(c2),
    .S(S_su[2]),
    .Co(c3)
);


sumador1b sum_4(
    .A(A_su[3]),
    .B(B_su[3]),
    .Ci(c3),
    .S(S_su[3]),
    .Co(Co_su)
);



endmodule
