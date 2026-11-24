# Lab05: Set de Instrucciones (ISA) y Unidad de Control en FPGA MAX 10

## Integrantes
* Cristian David Maldonado
* Anderson Stiven Malagon

---

## Tabla de Contenidos
1. [Documentación del Código HDL](#1-documentación-del-código-hdl-)
   - [unidad_control.v](src/unidad_control.v)
   - [top_procesador.v](src/top_procesador.v)
   - [rom_instrucciones.v](src/rom_instrucciones.v)
   - [banco_registros.v](src/banco_registros.v)
   - [alu_completa.v](src/alu_completa.v)
   - [uart_tx.v](src/uart_tx.v)
   - [procesador_tb.v](src/procesador_tb.v)
2. [Arquitectura del Set de Instrucciones (ISA) y Formato](#2-arquitectura-del-set-de-instrucciones-isa-y-formato-)
3. [Unidad de Control (FSM Moore) y Datapath Integrado](#3-unidad-de-control-fsm-moore-y-datapath-integrado-)
4. [Programa de Prueba Ejecutado](#4-programa-de-prueba-ejecutado-)
5. [Evidencias de Diseño, Simulación e Implementación en FPGA](#5-evidencias-de-diseño-simulación-e-implementación-en-fpga-)
6. [Conclusiones](#6-conclusiones-)
7. [Referencias](#7-referencias-)

---

## 1. Documentación del Código HDL :

A continuación se describen los módulos en Verilog HDL que conforman el procesador de 8 bits con instrucciones de 16 bits almacenados en la carpeta `src/`:

- **[unidad_control.v](src/unidad_control.v):** Máquina de estados finitos (FSM) de tipo **Moore** (todas sus salidas dependen exclusivamente del estado actual)[cite: 7, 8]. Gestiona el Contador de Programa (`pc_out`), el Registro de Instrucción (`IR` de 16 bits), la decodificación de campos (`opcode`, `rd`, `rs`, `rt`, `inmediato`), los pulsos de captura de operandos (`a_load`, `b_load`), el selector de escritura (`wsel`), los *handshakes* de espera (`alu_done`, `div_done`, `uart_ocupado`) y la señal de avance (`avanzar`)[cite: 7, 8].
- **[top_procesador.v](src/top_procesador.v):** Módulo estructural de nivel superior que interconecta la `unidad_control`, la memoria ROM de instrucciones, el banco de registros, los registros temporales `A_reg` y `B_reg`, la ALU (con multiplicador y divisor secuenciales), el transmisor UART y los periféricos de visualización (LEDs / displays de 7 segmentos de la tarjeta DE10-Lite).
- **[rom_instrucciones.v](src/rom_instrucciones.v):** Memoria de solo lectura (ROM) direccionada por `pc_out[3:0]` que entrega la palabra de instrucción `rom_data[15:0]` con el programa de prueba precargado[cite: 7, 8].
- **[banco_registros.v](src/banco_registros.v):** Banco de 8 registros de propósito general de 8 bits (`R0` a `R7`) direccionados mediante `bank_addr[2:0]`, gobernado por las señales de control `bank_read_en` y `bank_write_en` (manteniendo `R0` cableado a cero según la convención RISC)