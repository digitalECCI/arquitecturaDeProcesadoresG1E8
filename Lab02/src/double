`include "sumador_4_bits.v"
`include "7_seg.v"
`timescale 1s/1s



module double(
    input  [3:0]A_do,
    input  [3:0]B_do,
    input  sel_do,
    output [3:0] So_do,
    output Co_do,
    output reg [3:0] uni,
    output reg [3:0] des,
    output [6:0] uni_seg,
    output [6:0] des_seg

);


reg [12:0] mita;

restador_4 double_1(
    .A_su(A_do),
    .B_su(B_do),
    .sel(sel_do),
    .S_su(So_do),
    .Co_su(Co_do)
);


deco_7seg uni_7seg (
     .num(uni),
     .seg_out(uni_seg)
);


deco_7seg des_7seg (
     .num(des),
     .seg_out(des_seg)
);




always @(*) begin
        


        mita = {8'b00000000, Co_do, So_do};

        mita = mita << 1; //Paso 1

        mita = mita << 1; //Paso 2

        mita = mita << 1; //Paso 3


        if (mita [8:5] >= 5) begin
            mita [8:5] = mita [8:5] + 3;
        end


        mita = mita << 1; //paso 4


        if (mita[8:5] >= 5) begin
            mita[8:5] = mita[8:5] + 3;
        end


        mita = mita << 1; //paso 5

        uni  = mita[8:5];
        des  = mita[12:9];
    end

endmodule

