`timescale 1ns / 1ps
`include "principal.v"

module tb_procesador_top;

  
    reg clk;
    reg rst;
    reg [2:0] A;
    reg [2:0] B;
    reg carry_in;
    reg [2:0] opcode;
    reg [2:0] addr;
    reg write_en;
    reg read_en;

 
    wire [7:0] alu_result;
    wire zero;
    wire carry_out;
    wire negative;
    wire [7:0] data_out;

   
    principal uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .carry_in(carry_in),
        .opcode(opcode),
        .addr(addr),
        .write_en(write_en),
        .read_en(read_en),
        .alu_result(alu_result),
        .zero(zero),
        .carry_out(carry_out),
        .negative(negative),
        .data_out(data_out)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

  
    initial begin
        // 1. Configuración para GTKWave
        $dumpfile("simulacion_procesador.vcd"); // Nombre del archivo generado
        $dumpvars(0, tb_procesador_top);        // Guardar todas las variables del testbench

        // 2. Inicialización de señales y Reset
        rst = 1;
        A = 3'b000;
        B = 3'b000;
        carry_in = 0;
        opcode = 3'b000;
        addr = 3'b000;
        write_en = 0;
        read_en = 0;

        #10 rst = 0; // Apagar el reset después de 10ns

        // --- PRUEBA 1: Sumar 3 + 2 y guardar en el Registro 1 ---
        #10;
        A = 3'b011;       // 3 en binario
        B = 3'b010;       // 2 en binario
        opcode = 3'b000;  // Código ADD (Suma)
        addr = 3'b001;    // Seleccionar la dirección 1 del banco de registros
        write_en = 1;     // Ordenar que se escriba el resultado (5) en el registro
        read_en = 0;
        
        #10; // Esperar al siguiente flanco de reloj para que el banco guarde el dato
        write_en = 0;     // Apagar la escritura

        // Leer el Registro 1 para comprobar
        #10;
        read_en = 1;      // Ordenar lectura
        addr = 3'b001;    // Leer el registro 1 (data_out debe mostrar 5)

        // --- PRUEBA 2: Restar 7 - 2 y guardar en el Registro 2 ---
        #10;
        read_en = 0;      // Apagar lectura previa
        A = 3'b111;       // 7 en binario
        B = 3'b010;       // 2 en binario
        opcode = 3'b001;  // Código SUB (Resta)
        addr = 3'b010;    // Seleccionar la dirección 2
        write_en = 1;     // Ordenar escritura (el resultado 5 se guarda)
        
        #10; 
        write_en = 0;

        // Leer el Registro 2
        #10;
        read_en = 1;
        addr = 3'b010;    // (data_out debe mostrar 5)

        // --- PRUEBA 3: AND Lógico y guardar en el Registro 3 ---
        #10;
        read_en = 0;
        A = 3'b101;       // 5 en binario
        B = 3'b011;       // 3 en binario
        opcode = 3'b100;  // Código AND (101 & 011 = 001)
        addr = 3'b011;    // Seleccionar la dirección 3
        write_en = 1;     // Ordenar escritura (el resultado 1 se guarda)

        #10;
        write_en = 0;

        // Leer el Registro 3
        #10;
        read_en = 1;
        addr = 3'b011;    // (data_out debe mostrar 1)

        // Finalizar simulación
        #20;
        $finish;
    end

endmodule