// ============================================================
// UNIDAD DE CONTROL  (FSM fetch - decode - read - execute - writeback)
//
// Campos de la instrucción (IR de 16 bits):
//   opcode = IR[15:12]   rd = IR[11:9]   rs = IR[8:6]   rt = IR[5:3]
//   inmediato = IR[8:0]  (se usan los 8 bits bajos)
//
// Contiene PC e IR. Los registros de operandos A_reg / B_reg están en el top.
// Todas las salidas de control son de tipo Moore (dependen solo del estado).
//
// Sin "for".
// ============================================================
module unidad_control (
    input  wire        clk,
    input  wire        rst_n,

    // Memoria de instrucciones
    input  wire [15:0] rom_data,
    output wire [3:0]  pc_out,

    // Realimentación desde el datapath
    input  wire        alu_done,
    input  wire        div_done,
    input  wire        div_err,
    input  wire        uart_ocupado,
    input  wire        avanzar,       // 1 = se permite buscar la siguiente instrucción

    // Banco de registros
    output reg  [2:0]  bank_addr,
    output reg         bank_read_en,
    output reg         bank_write_en,

    // Datapath
    output reg  [1:0]  wsel,        // 00 ALU, 01 inmediato, 10 cociente, 11 A_reg (MOV)
    output reg         a_load,
    output reg         b_load,
    output reg         alu_start,
    output reg  [2:0]  alu_sel,
    output reg         div_start,
    output reg         uart_go,
    output wire [2:0]  uart_addr,
    output wire [7:0]  imm8,

    // Estado
    output wire        halted,
    output reg         div0_flag,
    output wire [15:0] ir_out         // instrucción actual (para visualizar)
);

    // ---------------- Códigos de operación (ISA) ----------------
    localparam OP_ADD  = 4'b0000,
               OP_SUB  = 4'b0001,
               OP_AND  = 4'b0010,
               OP_OR   = 4'b0011,
               OP_XOR  = 4'b0100,
               OP_CMP  = 4'b0101,
               OP_MUL  = 4'b0110,
               OP_DIV  = 4'b0111,
               OP_LI   = 4'b1000,
               OP_MOV  = 4'b1001,
               OP_OUT  = 4'b1010,
               OP_HALT = 4'b1111;

    // ---------------- Estados ----------------
    localparam S_FETCH      = 4'd0,
               S_DECODE     = 4'd1,
               S_RS         = 4'd2,
               S_RT         = 4'd3,
               S_CAPB       = 4'd4,
               S_ALU_START  = 4'd5,
               S_ALU_WAIT   = 4'd6,
               S_DIV_START  = 4'd7,
               S_DIV_WAIT   = 4'd8,
               S_WB         = 4'd9,
               S_UART_START = 4'd10,
               S_UART_WAIT  = 4'd11,
               S_HALT       = 4'd12;

    reg [3:0]  estado, sig_estado;
    reg [3:0]  pc;
    reg [15:0] ir;

    wire [3:0] opcode = ir[15:12];
    wire [2:0] rd     = ir[11:9];
    wire [2:0] rs     = ir[8:6];
    wire [2:0] rt     = ir[5:3];

    assign pc_out    = pc;
    assign imm8      = ir[7:0];
    assign uart_addr = rs;
    assign halted    = (estado == S_HALT);
    assign ir_out    = ir;

    // ---------------- Registros: estado, PC, IR, bandera div/0 ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado    <= S_FETCH;
            pc        <= 4'd0;
            ir        <= 16'hF000;
            div0_flag <= 1'b0;
        end else begin
            estado <= sig_estado;

            if (estado == S_FETCH && avanzar) begin
                ir <= rom_data;
                pc <= pc + 4'd1;
            end

            if (estado == S_DIV_WAIT && div_err)
                div0_flag <= 1'b1;
        end
    end

    // ---------------- Próximo estado ----------------
    always @(*) begin
        sig_estado = estado;
        case (estado)
            S_FETCH:  sig_estado = avanzar ? S_DECODE : S_FETCH;

            S_DECODE: begin
                case (opcode)
                    OP_HALT: sig_estado = S_HALT;
                    OP_LI:   sig_estado = S_WB;
                    OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR,
                    OP_CMP, OP_MUL, OP_DIV, OP_MOV, OP_OUT:
                             sig_estado = S_RS;
                    default: sig_estado = S_HALT;     // opcode inválido
                endcase
            end

            S_RS:     sig_estado = S_RT;
            S_RT:     sig_estado = S_CAPB;

            S_CAPB: begin
                case (opcode)
                    OP_DIV:  sig_estado = S_DIV_START;
                    OP_MOV:  sig_estado = S_WB;
                    OP_OUT:  sig_estado = S_UART_START;
                    default: sig_estado = S_ALU_START; // ADD SUB AND OR XOR CMP MUL
                endcase
            end

            S_ALU_START: sig_estado = S_ALU_WAIT;
            S_ALU_WAIT: begin
                if (alu_done) sig_estado = (opcode == OP_CMP) ? S_FETCH : S_WB;
                else          sig_estado = S_ALU_WAIT;
            end

            S_DIV_START: sig_estado = S_DIV_WAIT;
            S_DIV_WAIT: begin
                if (div_done || div_err) sig_estado = S_WB;
                else                     sig_estado = S_DIV_WAIT;
            end

            S_WB:     sig_estado = S_FETCH;

            S_UART_START: sig_estado = S_UART_WAIT;
            S_UART_WAIT: begin
                if (uart_ocupado) sig_estado = S_UART_WAIT;
                else              sig_estado = S_FETCH;
            end

            S_HALT:   sig_estado = S_HALT;

            default:  sig_estado = S_HALT;
        endcase
    end

    // ---------------- Selector de la ALU a partir del opcode ----------------
    always @(*) begin
        case (opcode)
            OP_ADD:  alu_sel = 3'b000;
            OP_SUB:  alu_sel = 3'b001;
            OP_CMP:  alu_sel = 3'b001;
            OP_MUL:  alu_sel = 3'b010;
            OP_OR:   alu_sel = 3'b011;
            OP_XOR:  alu_sel = 3'b101;
            OP_AND:  alu_sel = 3'b111;
            default: alu_sel = 3'b000;
        endcase
    end

    // ---------------- Salidas de control (Moore) ----------------
    always @(*) begin
        bank_addr     = rs;
        bank_read_en  = 1'b0;
        bank_write_en = 1'b0;
        wsel          = 2'b00;
        a_load        = 1'b0;
        b_load        = 1'b0;
        alu_start     = 1'b0;
        div_start     = 1'b0;
        uart_go   = 1'b0;

        case (estado)
            S_RS: begin
                bank_addr    = rs;
                bank_read_en = 1'b1;
            end

            S_RT: begin                       // llega el dato de rs; se pide el de rt
                bank_addr    = rt;
                bank_read_en = 1'b1;
                a_load       = 1'b1;
            end

            S_CAPB: b_load = 1'b1;            // llega el dato de rt

            S_ALU_START: alu_start = 1'b1;
            S_DIV_START: div_start = 1'b1;

            S_WB: begin
                bank_addr     = rd;
                bank_write_en = (rd != 3'd0); // R0 queda fijo en 0
                case (opcode)
                    OP_LI:   wsel = 2'b01;
                    OP_DIV:  wsel = 2'b10;
                    OP_MOV:  wsel = 2'b11;
                    default: wsel = 2'b00;
                endcase
            end

            S_UART_START: uart_go = 1'b1;

            default: ;
        endcase
    end

endmodule