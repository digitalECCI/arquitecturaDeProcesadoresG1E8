`timescale 1s/1s
`include "double.v"
`include "deco_7seg.v"
`include "antirrebote.v"



module multiplicador (
    input        clk,
    input        rst,     
    input        init,    
    input  [2:0] md,      
    input  [2:0] mr,      
    output reg [5:0] pp,  
    output reg       done,
    output [6:0]  display_uni,
    output [6:0]  display_des
);

    //----------------------------------------------------------
    // Estados
    //----------------------------------------------------------
    parameter START = 3'd0;
    parameter CHECK = 3'd1;
    parameter ADD   = 3'd2;
    parameter SHIFT = 3'd3;
    parameter END   = 3'd4;

    reg [2:0] estado;
    reg [2:0] siguiente;

    wire [3:0] uni;
    wire [3:0] des;

    wire rst_anti;
    wire init_anti;

    
    reg reset;
    reg sh;
    reg add;


    reg [5:0] a;
    reg [2:0] b;


    wire lsb_b;
    wire z;

    assign lsb_b = b[0];
    assign z     = (b[2:1] == 2'b00);  // B sera 0 despues del shift

    // MAQUINA DE ESTADOS

    always @(posedge clk or posedge rst) begin
        if (rst)
            estado <= START;
        else
            estado <= siguiente;
    end




    // Logica de siguiente estado
    always @(*) begin
        case (estado)
            START: begin
                if (init) siguiente = CHECK;
                else      siguiente = START;
            end

            CHECK: begin
                if (lsb_b) siguiente = ADD;
                else       siguiente = SHIFT;
            end

            ADD: begin
                siguiente = SHIFT;
            end

            SHIFT: begin
                if (z) siguiente = END;
                else   siguiente = CHECK;
            end

            END: begin
                siguiente = START;
            end

            default: begin
                siguiente = START;
            end
        endcase
    end


    always @(*) begin
        done  = 1'b0;
        reset = 1'b0;
        sh    = 1'b0;
        add   = 1'b0;
        case (estado)
            START: reset = 1'b1;
            CHECK: ;
            ADD:   add   = 1'b1;
            SHIFT: sh    = 1'b1;
            END:   done  = 1'b1;
            default: ;
        endcase
    end


    // DATAPACTH

    always @(posedge clk) begin
        if (reset) begin
            a  <= {3'b000, md};
            b  <= mr;
            pp <= 6'b000000;
        end
        else if (add) begin
            pp <= pp + a;
        end
        else if (sh) begin
            a <= a << 1;
            b <= b >> 1;
        end
    end

double  mi_conversor (
        .bin      (pp), 
        .decenas  (des),
        .unidades (uni)
    );

deco_7seg unid (
        .num       (uni),
        .seg_out   (display_uni)
);


deco_7seg desce (
        .num       (des),
        .seg_out   (display_des)
);

antirrebote anti_1 (
        .clk      (clk),
        .boton_in   (rst),
        .boton_out  (rst_anti)
);


antirrebote anti_2 (
        .clk        (clk),
        .boton_in   (init),
        .boton_out  (init_anti)
);



endmodule