        
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

#### 1.2 Diagramas


## Simulaciones 

### 1. Simulación del sumador/restador

#### 1.1 Descripción

#### 1.2 Diagrama


## Evidencias de implementación


## Conclusiones


## Referencias

