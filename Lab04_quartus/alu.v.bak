module alu_custom (
    input wire [2:0] A,        
    input wire [2:0] B,        
    input wire carry_in,       
    input wire [2:0] opcode,   
    output reg [7:0] result,   
    output reg zero,           
    output reg carry_out,      
    output reg negative      
);

    reg [8:0] temp_result;   
    
    // Extensión de las entradas de 3 bits a 8 bits (rellenando con ceros a la izquierda)
    wire [7:0] A_ext = {5'b00000, A};
    wire [7:0] B_ext = {5'b00000, B};

    always @(*) begin

        temp_result = 9'b0;
        carry_out = 1'b0;

        case(opcode)
            // -- Unidad Aritmética --[cite: 1]
            3'b000: begin // ADD
                temp_result = A_ext + B_ext + carry_in;
                carry_out = temp_result[8];
            end
            3'b001: begin // SUB (A - B)
                temp_result = A_ext - B_ext - carry_in;
                carry_out = temp_result[8];
            end
            3'b010: begin // INC (Incrementar A)
                temp_result = A_ext + 1'b1;
                carry_out = temp_result[8];
            end
            3'b011: begin // DEC (Decrementar A)
                temp_result = A_ext - 1'b1;
                carry_out = temp_result[8];
            end
            
            // -- Unidad Lógica --[cite: 1]
            3'b100: temp_result = {1'b0, A_ext & B_ext}; // AND
            3'b101: temp_result = {1'b0, A_ext | B_ext}; // OR
            3'b110: temp_result = {1'b0, A_ext ^ B_ext}; // XOR
            
            // Operación por defecto (opcode 3'b111 sin uso)
            default: temp_result = 9'b0;
        endcase

        result = temp_result[7:0]; 

    
        zero = (result == 8'b0) ? 1'b1 : 1'b0; 
        negative = result[7]; 
        
    
    end
endmodule