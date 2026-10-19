# Laboratorio 04: ALU, Banco de Registros y Transmisión UART

## Integrantes
- [Edwin Albeiro Blanco](https://github.com/Edwinal05)
- [Cristian David Maldonado](https://github.com/CristianMaldonadoTinjaca)
- [Anderson Stiven Malagon](https://github.com/andersonstmalagonal-svg)

---

## Índice
1. [De qué trata el proyecto](#1-de-qué-trata-el-proyecto)
2. [Cómo funciona el circuito por dentro](#2-cómo-funciona-el-circuito-por-dentro)
   - [El módulo de la ALU (`alu.v`)](#el-módulo-de-la-alu-aluv)
   - [El Banco de Registros (`bancoregistro.v`)](#el-banco-de-registros-bancoregistrov)
   - [El módulo UART (`uart.v`)](#el-módulo-uart-uartv)
   - [El módulo principal (`principal.v`)](#el-módulo-principal-principalv)
3. [Diagramas y esquemáticos](#3-diagramas-y-esquemáticos)
4. [Pruebas y simulación (GTKWave)](#4-pruebas-y-simulación-gtkwave)
5. [Prueba física en la FPGA](#5-prueba-física-en-la-fpga)
6. [Lo que aprendimos (Conclusiones)](#6-lo-que-aprendimos-conclusiones)

---

## 1. De qué trata el proyecto

El objetivo de este laboratorio es integrar tres componentes fundamentales de un procesador digital:
1. Una **ALU** que realiza los cálculos aritméticos (sumas, restas) y operaciones lógicas (AND, OR, XOR).
2. Un **banco de registros** que almacena temporalmente los resultados generados por la ALU.
3. Un módulo **UART** que toma la información leída del banco de registros y la envía de forma serial al computador para visualizarla en una terminal.

---

## 2. Cómo funciona el circuito por dentro

### El módulo de la ALU (`alu.v`)
Recibe dos operandos de 3 bits (`A` y `B`). Los extiende internamente a 8 bits rellenando con ceros y ejecuta la operación según el código `opcode`:

* **Aritmética:** `000` (Suma `ADD`), `001` (Resta `SUB`), `010` (Incrementar `A`) y `011` (Decrementar `A`).
* **Lógica:** `100` (`AND`), `101` (`OR`) y `110` (`XOR`).
* **Banderas de estado:** Evalúa si el resultado da cero (`zero`), si es negativo (`negative`) o si hubo desbordamiento (`carry_out`).

### El Banco de Registros (`bancoregistro.v`)
Consiste en un arreglo de 8 registros de 8 bits cada uno (`registros[0:7]`):
* **Escritura:** Al activar `write_en = 1` en un flanco de subida del reloj (`clk`), el resultado proveniente de la ALU se guarda en la dirección `addr`.
* **Lectura:** Al activar `read_en = 1`, el dato almacenado en la posición `addr` se coloca en el bus de salida `data_out`.
* **Reset:** Al activar `rst`, limpia todas las posiciones de memoria poniéndolas en cero.

### El módulo UART (`uart.v`)
Se encarga de la comunicación serial asíncrona hacia el computador a una velocidad de **9600 baudios** con un reloj de 50 MHz. Pasa por una máquina de estados que gestiona los tiempos de transmisión:
* Estados: Espera (`idle`), pausa (`delay`), bit de inicio (`start`), transmisión de los 8 bits de datos (`data`) y bit de parada (`stop`).

### El módulo principal (`principal.v`)
Conecta todos los bloques del sistema:
1. Conecta el resultado de la ALU a la entrada de datos del banco de registros.
2. La salida leída del banco de registros (`cable_data_out`) se conecta a la entrada de la UART.
3. Expone hacia el exterior las líneas de control, las banderas de estado y los pines de transmisión UART (`tx`, `busy`).

---

## 3. Diagramas y esquemáticos

<!-- Coloca aquí la imagen de tu diagrama de bloques general -->
![Diagrama de Bloques General](./fig/diagrama_bloques_top.png)

<!-- Coloca aquí la imagen del diagrama de estados de la UART -->
![FSM UART](./fig/fsm_uart.png)

---

## 4. Pruebas y simulación (GTKWave)

Probamos el funcionamiento del sistema en GTKWave mediante el testbench `principaltb.v`:

<!-- Coloca aquí la captura de tu simulación en GTKWave -->
![Simulación GTKWave](./fig/simulacion_gtkwave.png)

* **Prueba 1 (Suma):** Se calculó $A=3$ y $B=2$ (`opcode = 000`), obteniendo $5$. Se guardó en el registro `addr = 1` y al leerlo se comprobó que el valor $5$ salía hacia la UART.
* **Prueba 2 (Resta):** Se calculó $7 - 2$ (`opcode = 001`), guardando el resultado ($5$) en la posición `addr = 2`.
* **Prueba 3 (AND Lógico):** Se evaluó $5 \text{ AND } 3$ (`opcode = 100`), almacenando el valor $1$ en el registro `addr = 3`.

---

## 5. Prueba física en la FPGA

<!-- Coloca aquí la imagen o enlace de la prueba física -->
![Prueba en la tarjeta FPGA](./fig/evidencia_fpga.png)

---

## 6. Lo que aprendimos (Conclusiones)

* **Flujo continuo de datos:** Logramos conectar la ALU, la memoria interna (banco de registros) y la interfaz de salida (UART) en una sola cadena funcional, entendiendo la arquitectura básica de procesamiento.
* **Sincronización:** Comprobamos la importancia de controlar adecuadamente las señales de habilitación de lectura y escritura junto al reloj para garantizar que no se pierdan ni se sobrescriban los datos guardados.
* **Verificación externa:** El uso del protocolo UART facilitó la inspección de los datos almacenados en memoria directamente desde la terminal del computador.