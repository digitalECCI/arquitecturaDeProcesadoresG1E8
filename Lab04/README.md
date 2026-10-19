# Laboratorio 04: ALU, Banco de Registros y Transmisión UART

## Integrantes
* **Integrante 1:** Nombre Apellido - *Correo / Nombre de usuario de GitHub*
* **Integrante 2:** Nombre Apellido - *Correo / Nombre de usuario de GitHub*
* **Integrante 3:** Nombre Apellido - *Correo / Nombre de usuario de GitHub*

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

El objetivo de este lab es juntar tres partes esenciales de un sistema digital:
1. Una **ALU** que hace los cálculos (sumas, restas y operaciones lógicas).
2. Un **banco de registros** que guarda los resultados de la ALU en memoria.
3. Un módulo **UART** para mandar esos datos guardados hacia el computador por cable serial y verlos en una terminal (pantalla).

Con esto probamos el flujo completo: procesamos datos, los guardamos temporalmente y los enviamos al exterior.

---

## 2. Cómo funciona el circuito por dentro

### El módulo de la ALU (`alu.v`)
Recibe dos números de 3 bits (`A` y `B`). Para trabajar cómodamente, los rellena con ceros a la izquierda hasta volverlos de 8 bits. Según el código `opcode` que le mandemos, realiza una operación:

* **Suma y Resta:** Usa `000` para sumar y `001` para restar (soporta acarreo con `carry_in`).
* **Modificadores:** Con `010` incrementa en 1 el valor de `A`, y con `011` lo decrementa.
* **Operaciones lógicas:** Aplica las compuertas `AND` (`100`), `OR` (`101`) y `XOR` (`110`).
* **Banderas:** Si el resultado da cero, prende la señal `zero`. Si es negativo, prende `negative`. Si hubo desbordamiento, activa `carry_out`.

### El Banco de Registros (`bancoregistro.v`)
Es una pequeña memoria de 8 posiciones (de la `0` a la `7`), donde cada posición guarda un dato de 8 bits:
* **Para guardar:** Cuando activamos `write_en` en 1 y le damos un pulso de reloj, el dato que viene de la ALU se almacena en la dirección `addr`.
* **Para leer:** Cuando activamos `read_en` en 1, el módulo saca por `data_out` lo que esté guardado en la dirección `addr`.
* Si presionamos el botón de reset (`rst`), las 8 posiciones de memoria se limpian y quedan en cero.

### El módulo UART (`uart.v`)
Se encarga de enviar el dato seleccionado del banco de registros hacia el computador de bit en bit. 
* Trabaja a una velocidad estándar de **9600 baudios** usando el reloj de la FPGA de 50 MHz.
* Tiene un contador de pausa que espera un tiempo entre transmisiones para no saturar la pantalla.
* Pasa por 5 estados sencillos: espera (`idle`), pausa (`delay`), envía el bit de arranque (`start`), transmite los 8 bits del dato uno por uno (`data`) y cierra la transmisión con el bit de parada (`stop`).

### El módulo principal (`principal.v`)
Es el que conecta todo como un rompecabezas:
1. Conecta las salidas de la ALU directamente a la entrada del banco de registros.
2. Toma la salida de lectura del banco de registros (`cable_data_out`) y se la entrega al módulo UART.
3. Saca las señales `tx` (para el cable serial) y `busy` (para saber si la UART está ocupada) hacia afuera.

---

## 3. Diagramas y esquemáticos

*Aquí colocaremos el esquema de cómo se conectan los módulos entre sí y el diagrama del flujo de estados de la UART:*

<!-- Coloca aquí la imagen de tu diagrama de bloques general -->
![Diagrama de Bloques General](./fig/diagrama_bloques_top.png)

<!-- Coloca aquí la imagen del diagrama de estados de la UART -->
![FSM UART](./fig/fsm_uart.png)

---

## 4. Pruebas y simulación (GTKWave)

Probamos el funcionamiento completo en GTKWave usando el banco de pruebas `principaltb.v`:

<!-- Coloca aquí la captura de tu simulación en GTKWave -->
![Simulación GTKWave](./fig/simulacion_gtkwave.png)

* **Prueba de Suma:** Le dimos $A=3$ y $B=2$ en modo suma (`opcode = 000`). La ALU calculó $5$, lo guardamos en la dirección `001` y al leer ese registro, efectivamente salió un $5$.
* **Prueba de Resta:** Probamos $7 - 2$ (`opcode = 001`), dando $5$, guardado correctamente en la posición `010`.
* **Prueba Lógica (AND):** Evaluamos la operación entre $5$ y $3$ (`101 AND 011`), obteniendo $1$ en la dirección `011`.

---

## 5. Prueba física en la FPGA

*Aquí irán las fotografías o el enlace al video mostrando el funcionamiento en vivo con los switches de la tarjeta y la consola en el PC:*

<!-- Coloca aquí la imagen o enlace de evidencia -->
![Prueba en la tarjeta FPGA](./fig/evidencia_fpga.png)

---

## 6. Lo que aprendimos (Conclusiones)

* **Todo conectado en cadena:** Entendimos cómo se mueven los datos dentro de un procesador básico. Lo que calcula la ALU pasa directo a guardarse en memoria y de ahí lo podemos mandar al exterior sin enredos.
* **El reloj importa:** Trabajar con el banco de registros nos dejó claro que para guardar información hay que estar bien sincronizados con el reloj (`clk`) y no dejar señales flotando.
* **La utilidad de la UART:** Ver los datos en una terminal de computador en lugar de depender solo de bombillos LED ayuda muchísimo a entender si el circuito está respondiendo bien a lo que guardamos en los registros.