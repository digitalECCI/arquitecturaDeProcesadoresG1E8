        
# Lab01 - Sumador/Restador de 4 bits

# Integrantes
    * [<!-- EDWIN ALBEIRO BLANCO. -->](<!-- Remplace aqui link de usario 1 de github -->) 
    * [<!-- CRISTIAN DAVID MALDONADO. -->](<!-- Remplace aqui link de usario 2 de github -->) 
    * [<!-- ANDERSON STIVEN MALAGON. -->](https://github.com/andersonstmalagonal-svg) 
# Informe

Indice:

1. [Documentación](#documentación-de-los-circuitos-implementados-implementado)
3. [Simulaciones](#simulaciones)
4. [Evidencias de implementación](#evidencias-de-implementación)
5. [Preguntas](#preguntas)
6. [Conclusiones](#conclusiones)
7. [Referencias](#referencias)

## Documentación del diseño implementado

### 1. Sumador/Restador
1. Sumador/Restador1.1 DescripciónEl circuito sumador/restador de 4 bits implementado es un sistema lógico combinacional diseñado para realizar operaciones aritméticas de adición y sustracción binaria sobre dos operandos de 4 bits ($A_3A_2A_1A_0$ y $B_3B_2B_1B_0$). La selección de la operación aritmética a ejecutar se define mediante una única señal de control o modo ($M$).La arquitectura del sistema se fundamenta en la interconexión en cascada de cuatro sumadores completos. Para lograr la dualidad de la operación utilizando el mismo bloque sumador, el circuito emplea la aritmética del complemento a 2. Mientras el operando $A$ ingresa directamente a las terminales de los sumadores, cada bit del operando $B$ pasa previamente por una compuerta lógica XOR, compartiendo la segunda entrada de la compuerta con la señal de control $M$. A su vez, esta línea de control $M$ se conecta directamente al acarreo de entrada inicial ($C_{in}$) del bit menos significativo.
#### 1.1 Descripción
- Modo Suma ($Sel = 0$): Al establecer la señal de control en un estado lógico bajo, las compuertas XOR actúan como adaptadores transparentes, permitiendo el paso de los bits del operando $B$ sin alteraciones lógicas ($B \oplus 0 = B$). Dado que el acarreo de entrada inicial es 0, la topología en cascada ejecuta una adición binaria estándar: $S = A + B$.

- Modo Resta ($Sel = 1$): Al establecer la señal de control en un estado lógico alto, las compuertas XOR actúan como inversores, entregando a los sumadores el complemento a 1 del operando $B$ ($\bar{B}$). Simultáneamente, este estado lógico alto ingresa como un 1 en el acarreo de entrada inicial del circuito. Esta suma de una unidad al valor invertido completa matemáticamente el complemento a 2. En consecuencia, el hardware procesa la operación $S = A + \bar{B} + 1$, lo cual equivale aritméticamente a la sustracción $S = A - B$.
#### 1.2 Diagramas
<img width="671" height="310" alt="image" src="https://github.com/user-attachments/assets/5295b0d7-7aa8-499e-afce-20f5469a4451" />


## Simulaciones 

### 1. Simulación del sumador/restador

#### 1.1 Descripción
* [Restador de 4 bits](.fig/Restador_4_bits)
* [Testbench del Restador](./Restador_4_bits_testbench)
* [Sumador de 1 bit](./Sumador_1_bit).
#### 1.2 Diagrama


## Evidencias de implementación


## Conclusiones


## Referencias

