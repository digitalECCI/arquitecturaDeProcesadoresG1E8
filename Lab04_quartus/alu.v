module alu_custom (
    input  wire [2:0] A,
    input  wire [2:0] B,
    input  wire       carry_in,
    input  wire [2:0] opcode,
    output reg  [7:0] result,
    output reg        zero,
    output reg        carry_out,
    output reg        negative
);

    always @(*) begin
        result    = 8'b0;
        carry_out = 1'b0;

        case (opcode)
            3'b000: {carry_out, result} = A + B ;  // A + B + Cin
            3'b001: {carry_out, result} = A - B ;  // A - B - Bin (borrow)
            3'b010: {carry_out, result} = A + 3'd1;          // A + 1
            3'b011: {carry_out, result} = A - 3'd1;          // A - 1
            3'b100: result = A & B;                          // AND
            3'b101: result = A | B;                          // OR
            3'b110: result= A ^ B;                          // XOR
            3'b111: result = A * B;                               // multiplicación
            default: result = 8'b0;
        endcase

        zero     = (result == 8'b0);
        negative = (opcode == 3'b111) ? 1'b0 : result[2];
    end

endmodule