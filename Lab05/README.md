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

- **[unidad_control.v](src/unidad_control.v):** Máquina de estados finitos (FSM) de tipo **Moore** (todas sus salidas dependen exclusivamente del estado actual). Gestiona el Contador de Programa (`pc_out`), el Registro de Instrucción (`IR` de 16 bits), la decodificación de campos (`opcode`, `rd`, `rs`, `rt`, `inmediato`), los pulsos de captura de operandos (`a_load`, `b_load`), el selector de escritura (`wsel`), los *handshakes* de espera (`alu_done`, `div_done`, `uart_ocupado`) y la señal de avance (`avanzar`).
- **[top_procesador.v](src/top_procesador.v):** Módulo estructural de nivel superior que interconecta la `unidad_control`, la memoria ROM de instrucciones, el banco de registros, los registros temporales `A_reg` y `B_reg`, la ALU (con multiplicador y divisor secuenciales), el transmisor UART y los periféricos de visualización (LEDs / displays de 7 segmentos de la tarjeta DE10-Lite).
- **[rom_instrucciones.v](src/rom_instrucciones.v):** Memoria de solo lectura (ROM) direccionada por `pc_out[3:0]` que entrega la palabra de instrucción `rom_data[15:0]` con el programa de prueba precargado.
- **[banco_registros.v](src/banco_registros.v):** Banco de 8 registros de propósito general de 8 bits (`R0` a `R7`) direccionados mediante `bank_addr[2:0]`, gobernado por las señales de control `bank_read_en` y `bank_write_en` (manteniendo `R0` cableado a cero según la convención RISC).
- **[alu_completa.v](src/alu_completa.v):** Unidad aritmético-lógica de 8 bits que ejecuta operaciones combinacionales (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `CMP`) y secuenciales (`MUL` y `DIV`), recibiendo `alu_sel[2:0]` y `alu_start` y reportando finalización mediante `alu_done`, `div_done` y `div_err`.
- **[uart_tx.v](src/uart_tx.v):** Transmisor serial asíncrono (UART) encargado de enviar por el pin TX el dato cargado en `A_reg` al ejecutar la instrucción `OUT`, indicando su estado mediante la bandera `uart_ocupado`.
- **[procesador_tb.v](src/procesador_tb.v):** Banco de pruebas (*Testbench*) utilizado para verificar ciclo a ciclo el recorrido completo *Fetch–Decode–Execute–Writeback*, los tiempos de espera de multiplicación/división/UART y el resultado final `(5 + 3) * 5 = 40`.

---

## 2. Arquitectura del Set de Instrucciones (ISA) y Formato :

El procesador utiliza una arquitectura **Load/Store con instrucciones de ancho fijo de 16 bits**, operando sobre datos de **8 bits** y **8 registros de propósito general (`R0`–`R7`)**.

### Formatos de Instrucción (16 bits)

| Formato | `IR[15:12]` (4 bits) | `IR[11:9]` (3 bits) | `IR[8:6]` (3 bits) | `IR[5:3]` (3 bits) | `IR[2:0]` (3 bits) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Tipo R** (Registro-Registro) | `opcode` | `rd` (Destino) | `rs` (Fuente 1) | `rt` (Fuente 2) | Sin uso (`---`) |
| **Tipo I** (Inmediato) | `opcode` | `rd` (Destino) | `inmediato[8:6]` | `inmediato[5:3]` | `inmediato[2:0]` (se toman `IR[7:0]`) |

### Tabla del Set de Instrucciones (ISA)

| `opcode` | Mnemónico | Tipo | Operación | Descripción Funcional en el Datapath |
| :---: | :---: | :---: | :--- | :--- |
| `0000` | **ADD** | R | `rd = rs + rt` | Suma los operandos cargados en `A_reg` y `B_reg` mediante la ALU. |
| `0001` | **SUB** | R | `rd = rs - rt` | Resta `A_reg - B_reg` mediante la ALU. |
| `0010` | **AND** | R | `rd = rs & rt` | Operación lógica AND bit a bit. |
| `0011` | **OR** | R | `rd = rs \| rt` | Operación lógica OR bit a bit. |
| `0100` | **XOR** | R | `rd = rs ^ rt` | Operación lógica XOR bit a bit. |
| `0101` | **CMP** | R | `rs - rt` (Banderas) | Compara `rs` y `rt` actualizando banderas de estado sin sobrescribir `rd`. |
| `0110` | **MUL** | R | `rd = rs * rt` | Lanza el multiplicador secuencial (`alu_start`) y espera `alu_done`. |
| `0111` | **DIV** | R | `rd = rs / rt` | Lanza el divisor secuencial y espera `div_done` (validando `div_err`). |
| `1000` | **LI** | I | `rd = inmediato` | Carga el valor inmediato `IR[7:0]` directo en `rd` (`wsel = 2'b01`). |
| `1001` | **MOV** | R | `rd = rs` | Transfiere el contenido de `rs` (vía `A_reg`) hacia `rd` (`wsel = 2'b11`). |
| `1010` | **OUT** | R | `UART_TX <- rs` | Transmite el valor de `rs` por el puerto serial UART esperando `~uart_ocupado`. |
| `1111` | **HALT** | — | Detener CPU | Congela la FSM en un estado terminal hasta recibir un `rst_n`. |

---

## 3. Unidad de Control (FSM Moore) y Datapath Integrado :

La unidad de control (`unidad_control.v`) implementa una máquina de estados de tipo **Moore** sincronizada por flanco de reloj (`clk`) y reinicio activo en bajo (`rst_n`). Debido a que el banco de registros comparte un único bus de direccionamiento (`bank_addr[2:0]`), la captura de operandos de las instrucciones Tipo R se realiza secuencialmente mediante los registros temporales **`A_reg`** y **`B_reg`** ubicados en el módulo `top`:

1. **Fetch (Búsqueda):** Coloca `pc_out` en la ROM, captura `rom_data` en el registro `IR[15:0]` e incrementa el contador de programa cuando `avanzar == 1`.
2. **Decode / Lectura de Operandos (`a_load`, `b_load`):**
   - Selecciona `bank_addr = rs` y activa `bank_read_en` para capturar el primer operando en `A_reg` (`a_load = 1`).
   - En instrucciones de dos operandos (`ADD`, `SUB`, `MUL`, `DIV`, etc.), selecciona `bank_addr = rt` y activa `b_load = 1` para capturar el segundo operando en `B_reg`.
3. **Execute (Ejecución y *Handshake*):**
   - Configura `alu_sel[2:0]` a partir de `opcode[2:0]`.
   - Para operaciones secuenciales (`MUL`, `DIV`) activa `alu_start` y permanece en un estado de espera hasta detectar `alu_done == 1` o `div_done == 1`.
   - Para `OUT`, dispara el envío serial y espera a que `uart_ocupado` regrese a `0`.
4. **Writeback (Escritura en Registro Destino):**
   - Configura el multiplexor de escritura mediante `wsel[1:0]`:
     - `00`: Resultado de la ALU / Multiplicador.
     - `01`: Dato inmediato (`IR[7:0]`, instrucción `LI`).
     - `10`: Cociente del divisor (`DIV`).
     - `11`: Contenido de `A_reg` (instrucción `MOV`).
   - Apunta `bank_addr = rd` y activa `bank_write_en = 1` durante un ciclo de reloj.

---

## 4. Programa de Prueba Ejecutado :

Para validar tanto las operaciones combinacionales como el *handshake* secuencial (`MUL`) y la salida externa (`OUT`), se cargó en la memoria ROM el cálculo de `(5 + 3) * 5 = 40` (`0x28` en hexadecimal, carácter `'('` en ASCII):

```assembly
0x0: LI   R1, 5        ; R1 <- 0x05 (5 decimal)
0x1: LI   R2, 3        ; R2 <- 0x03 (3 decimal)
0x2: ADD  R3, R1, R2   ; R3 <- 5 + 3 = 8 (0x08)
0x3: MUL  R4, R3, R1   ; R4 <- 8 * 5 = 40 (0x28) - verifica handshake start/done
0x4: OUT  R4           ; Envía 0x28 (40) por UART TX
0x5: HALT              ; Detiene la ejecución del procesador