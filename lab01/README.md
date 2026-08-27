        
# Lab01 - Sumador/Restador de 4 bits

# Integrantes
    * [<!-- EDWIN ALBEIRO BLANCO. -->](<!-- Remplace aqui link de usario 1 de github -->) 
    * [<!-- CRISTIAN DAVID MALDONADO. -->](<!-- Remplace aqui link de usario 2 de github -->) 
    * [<!-- ANDERSON STIVEN MALAGON. -->](https://github.com/andersonstmalagonal-svg) 
# Informe

Indice:

1. [Documentación](#documentación-de-los-circuitos-implementados-implementado)
3. [Simulaciones](#simulaciones)
5. [Evidencias de implementación](#evidencias-de-implementación)
6. [Preguntas](#preguntas)
7. [Conclusiones](#conclusiones)
9. [Referencias](#referencias)

## 1 Documentación del diseño implementado
### 1. sumador_1_bit
# Sumador Completo de 1 Bit (1-bit Full Adder)

## Descripción General
El **sumador completo de 1 bit** es un circuito combinacional fundamental en la arquitectura de procesadores. Realiza la suma aritmética de dos bits de entrada ($A$ y $B$), tomando en cuenta un bit de acarreo de entrada ($C_{sel}$) proveniente de un nivel o etapa anterior. Genera dos salidas: la suma ($S$) y el acarreo de salida ($C_{out}$).

## Diagrama de Bloques e Interfaz

### Entradas y Salidas
| Puerto | Tipo | Descripción |
| :---: | :---: | :--- |
| `A` | Entrada | Primer bit de entrada a sumar. |
| `B` | Entrada | Segundo bit de entrada a sumar. |
| `Sel` | Entrada | Acarreo de entrada (*Carry-in*). |
| `S` | Salida | Resultado de la suma (*Sum*). |
| `Cout` | Salida | Acarreo de salida (*Carry-out*). |

---

## Tabla de Verdad

| $A$ | $B$ | $C_{Cin}$ | $S$ (Suma) | $C_{out}$ (Acarreo) |
| :-: | :-: | :------: | :--------: | :-----------------: |
|  0  |  0  |    0     |     0      |          0          |
|  0  |  0  |    1     |     1      |          0          |
|  0  |  1  |    0     |     1      |          0          |
|  0  |  1  |    1     |     0      |          1          |
|  1  |  0  |    0     |     1      |          0          |
|  1  |  0  |    1     |     0      |          1          |
|  1  |  1  |    0     |     0      |          1          |
|  1  |  1  |    1     |     1      |          1          |

---

## Ecuaciones Boleanas

Las expresiones lógicas simplificadas para las salidas son las siguientes:

* **Suma ($S$):**
  $$S = A \oplus B \oplus C_{in}$$

* **Acarreo de salida ($C_{out}$):**
  $$C_{out} = (A \cdot B) + (C_{in} \cdot (A \oplus B))$$


  
### 1.1 sumador_4_bits


# Sumador de 4 Bits (Ripple Carry Adder)

## Descripción General
Un **Sumador de 4 Bits** es un circuito combinacional capaz de sumar dos números binarios de 4 bits cada uno ($A$ y $B$), además de considerar un acarreo inicial de entrada ($C_{in}$). El circuito genera un resultado de 4 bits para la suma ($S$) y un bit final de acarreo de salida ($C_{out}$).

Esta implementación se basa en la arquitectura de **acarreo en cascada (Ripple Carry)**, conectando en serie 4 sumadores completos de 1 bit.

---

## Interfaz de Entradas y Salidas

| Puerto | Ancho de Bits | Tipo | Descripción |
| :---: | :---: | :---: | :--- |
| `A` | 4 bits ($A_3, A_2, A_1, A_0$) | Entrada | Primer operando de 4 bits. |
| `B` | 4 bits ($B_3, B_2, B_1, B_0$) | Entrada | Segundo operando de 4 bits. |
| `Cin` | 1 bit | Entrada | Acarreo inicial de entrada. |
| `S` | 4 bits ($S_3, S_2, S_1, S_0$) | Salida | Resultado de la suma. |
| `Cout` | 1 bit | Salida | Acarreo final de salida (Desbordamiento de 4 bits). |

---

## Principio de Funcionamiento

El circuito interconecta cuatro módulos **Sumadores Completo de 1 bit** ($FA_0, FA_1, FA_2, FA_3$):

1. **Bit 0 (LSB):** $FA_0$ suma los bits menos significativos $A_0$ y $B_0$ con el acarreo de entrada $C_{in}$, generando la suma $S_0$ y el acarreo intermedio $C_1$.
2. **Bit 1:** $FA_1$ suma $A_1$ y $B_1$ utilizando el acarreo $C_1$, generando $S_1$ y el acarreo $C_2$.
3. **Bit 2:** $FA_2$ suma $A_2$ y $B_2$ utilizando el acarreo $C_2$, generando $S_2$ y el acarreo $C_3$.
4. **Bit 3 (MSB):** $FA_3$ suma los bits más significativos $A_3$ y $B_3$ utilizando el acarreo $C_3$, generando la suma $S_3$ y el acarreo final $C_{out}$.

---

## Ecuaciones Lógicas Generales

Para cada etapa $i$ (donde $i = 0, 1, 2, 3$):

* **Suma por Bit:** 
  $$S_i = A_i \oplus B_i \oplus C_i$$

* **Acarreo Siguiente:** 
  $$C_{i+1} = (A_i \cdot B_i) + (C_i \cdot (A_i \oplus B_i))$$

*(Donde $C_0 = C_{in}$ y $C_4 = C_{out}$)*

---

## Ejemplos de Funcionamiento Aritmético

* **Caso 1: Suma simple sin acarreo final**
  * $A = 0101_2$ (5 en decimal)
  * $B = 0011_2$ (3 en decimal)
  * $C_{in} = 0$
  * **Resultado:** $S = 1000_2$ (8 en decimal), $C_{out} = 0$

* **Caso 2: Suma con acarreo final (Desbordamiento de 4 bits)**
  * $A = 1100_2$ (12 en decimal)
  * $B = 0101_2$ (5 en decimal)
  * $C_{in} = 0$
  * **Resultado:** $S = 0001_2$ (1 en decimal), $C_{out} = 1$ *(Suma total = 17)*

---

## Diagrama del Circuito 



### 1.2 Sumador/Restador
1. Sumador/Restador1.1 DescripciónEl circuito sumador/restador de 4 bits implementado es un sistema lógico combinacional diseñado para realizar operaciones aritméticas de adición y sustracción binaria sobre dos operandos de 4 bits ($A_3A_2A_1A_0$ y $B_3B_2B_1B_0$). La selección de la operación aritmética a ejecutar se define mediante una única señal de control o modo ($M$).La arquitectura del sistema se fundamenta en la interconexión en cascada de cuatro sumadores completos. Para lograr la dualidad de la operación utilizando el mismo bloque sumador, el circuito emplea la aritmética del complemento a 2. Mientras el operando $A$ ingresa directamente a las terminales de los sumadores, cada bit del operando $B$ pasa previamente por una compuerta lógica XOR, compartiendo la segunda entrada de la compuerta con la señal de control $M$. A su vez, esta línea de control $M$ se conecta directamente al acarreo de entrada inicial ($C_{in}$) del bit menos significativo.
#### 1.1 Descripción
- Modo Suma ($Sel = 0$): Al establecer la señal de control en un estado lógico bajo, las compuertas XOR actúan como adaptadores transparentes, permitiendo el paso de los bits del operando $B$ sin alteraciones lógicas ($B \oplus 0 = B$). Dado que el acarreo de entrada inicial es 0, la topología en cascada ejecuta una adición binaria estándar: $S = A + B$.

- Modo Resta ($Sel = 1$): Al establecer la señal de control en un estado lógico alto, las compuertas XOR actúan como inversores, entregando a los sumadores el complemento a 1 del operando $B$ ($\bar{B}$). Simultáneamente, este estado lógico alto ingresa como un 1 en el acarreo de entrada inicial del circuito. Esta suma de una unidad al valor invertido completa matemáticamente el complemento a 2. En consecuencia, el hardware procesa la operación $S = A + \bar{B} + 1$, lo cual equivale aritméticamente a la sustracción $S = A - B$.
#### 1.2 Diagramas
<img width="671" height="310" alt="image" src="https://github.com/user-attachments/assets/5295b0d7-7aa8-499e-afce-20f5469a4451" />


## Simulaciones 

### 1. Simulación del sumador/restador

#### 1.1 Descripción del código
        ### 1.1.1 retador de 4 bits ###
* [Restador de 4 bits](./src/Restador_4_bits)
* [Testbench del Restador](.src/Restador_4_bits_testbench)
* [Sumador de 1 bit](.src/Sumador_1_bit).
#### 1.2 Diagrama


## Evidencias de implementación


## Conclusiones


## Referencias

