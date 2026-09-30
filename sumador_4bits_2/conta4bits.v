`include "conta.v"


module sumador4b(
    
input  [3:0] A_tb,
input  [3:0] B_tb,
input  Ci_tb,
output [3:0] S_tb,
output C0_tb

);

wire C1;
wire C2;
wire C3;



sumador1b uut1(
    .A(A_tb[0]),
    .B(B_tb[0]),
    .Ci(Ci_tb),
    .S(S_tb[0]),
    .Co(C1)
);
sumador1b uut2(
    .A(A_tb[1]),
    .B(B_tb[1]),
    .Ci(C1),
    .S(S_tb[1]),
    .Co(C2)
);

sumador1b uut3(
    .A(A_tb[2]),
    .B(B_tb[2]),
    .Ci(C2),
    .S(S_tb[2]),
    .Co(C3)
);
sumador1b uut4(
    .A(A_tb[3]),
    .B(B_tb[3]),
    .Ci(C3),
    .S(S_tb[3]),
    .Co(C0_tb)
);


endmodule