module principal (
    input wire clk,
    input wire rst_n,        
    input wire [2:0] ap,          
    input wire [2:0] bp,         
    input wire carry_in,
    input wire [2:0] opcode,
    input wire [2:0] addr,       
    input wire write_en,
    input wire read_en,
    output wire [7:0] alu_result, 
    output wire zero,
    output wire carry_out,
    output wire negative,
    
	 
    output wire tx,
    output wire busy
);

    wire [7:0] cable_alu_resultado;
    wire [7:0] cable_data_out; 
    
    assign alu_result = cable_alu_resultado;
    assign data_out = cable_data_out; 

    
    alu_custom u_alu (
        .A(ap),                           
        .B(bp),                           
        .carry_in(carry_in),
        .opcode(opcode),
        .result(cable_alu_resultado),    
        .zero(zero),
        .carry_out(carry_out),
        .negative(negative)
    );
    
    
    banco_registros u_banco_reg (
        .clk(clk),
        .rst_btn(rst_n),                 
        .data_in(cable_alu_resultado),
        .addr(addr),                     
        .write_en(write_en),             
        .read_en(read_en),
        .data_out(cable_data_out)     
    );

    
    uart u_uart (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(cable_data_out),     
        .tx(tx),
        .busy(busy)
    );

endmodule