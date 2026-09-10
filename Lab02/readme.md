#  Descripción Detallada del Diseño de Hardware

Para que todo funcione de manera ordenada en la FPGA, el sistema se diseñó por módulos. Básicamente, dividimos el proyecto en tres partes clave: primero se procesan los números en la unidad aritmética, después pasamos los datos por el bloque Double Dabble para hacer la conversión de código, y por último entra en juego la etapa de decodificación para mostrar la información en la pantalla de forma dinámica.

---

## 1. Módulo Operacional: Sumador / Restador de 4 bits

Este módulo funciona como una ALU (Unidad Aritmético Lógica) básica. Realiza las operaciones aritméticas empleando la lógica de complemento a dos para el manejo de números negativos, separando la magnitud del resultado y su signo.

### Tabla de Puertos
| Puerto | Dirección | Tamaño | Descripción |
| :--- | :---: | :---: | :--- |
| `A` | Entrada | 4 bits | Operando A. |
| `B` | Entrada | 4 bits | Operando B. |
| `M` | Entrada | 1 bit | Selector de operación (0 = Suma, 1 = Resta). |
| `Result` | Salida | 4 bits | Valor absoluto (magnitud) del resultado. |
| `Sign` | Salida | 1 bit | Bit de signo (`0` = Positivo, `1` = Negativo). |

### Lógica de Operación
| `M` (Selector) | Operación Lógica | Comportamiento del Signo (`Sign`) |
| :---: | :--- | :--- |
| **0** | `A + B` | Siempre `0` (en suma de positivos, se asume sin signo). |
| **1** | `A - B` | `0` si $A \ge B$ (Positivo). <br> `1` si $A < B$ (Negativo, resultado en complemento a 2 convertido a magnitud). |

---

## 2. Módulo de Conversión: Binario a BCD (Double Dabble)

Dado que los displays de 7 segmentos muestran dígitos en formato decimal (0-9), el resultado binario debe ser traducido. Para evitar el uso de divisores aritméticos (que consumen muchos recursos en hardware), se implementó el algoritmo **Shift-and-Add-3 (Double Dabble)**.

### Tabla de Puertos
| Puerto | Dirección | Tamaño | Descripción |
| :--- | :---: | :---: | :--- |
| `Bin_in` | Entrada | 4 bits | Magnitud binaria proveniente del Sumador/Restador. |
| `BCD_Decenas`| Salida | 4 bits | Dígito BCD correspondiente a las decenas. |
| `BCD_Unidades`| Salida | 4 bits | Dígito BCD correspondiente a las unidades. |

### Regla de Lógica Combinacional (Por cada iteración/shift)
| Condición del Nibble (4 bits) | Acción ejecutada por el Hardware |
| :--- | :--- |
| Valor actual **< 5** (`0000` a `0100`) | Ninguna (solo desplazamiento a la izquierda). |
| Valor actual **≥ 5** (`0101` a `1001`) | **Suma +3** (`0011`) antes del siguiente desplazamiento. |

---

## 3. Módulo Decodificador 7 Segmentos y Visualización Dinámica

Este bloque traduce los códigos BCD a los patrones de encendido físicos de los LEDs del display. Además, incorpora un **multiplexor con divisor de frecuencia** para engañar al ojo humano (persistencia de la visión) y mostrar datos diferentes en 3 displays físicos utilizando un solo bus de datos de 7 hilos.

### Tabla de Verdad: Decodificador BCD a 7 Segmentos
*(Nota: Lógica mostrada para display genérico. Los valores `1` o `0` para encender dependerán de si la tarjeta usa Ánodo o Cátodo común).*

| Dígito Decimal | BCD (Entrada) | a | b | c | d | e | f | g |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | `0000` | 1 | 1 | 1 | 1 | 1 | 1 | 0 |
| **1** | `0001` | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| **2** | `0010` | 1 | 1 | 0 | 1 | 1 | 0 | 1 |
| **3** | `0011` | 1 | 1 | 1 | 1 | 0 | 0 | 1 |
| **4** | `0100` | 0 | 1 | 1 | 0 | 0 | 1 | 1 |
| **5** | `0101` | 1 | 0 | 1 | 1 | 0 | 1 | 1 |
| **6** | `0110` | 1 | 0 | 1 | 1 | 1 | 1 | 1 |
| **7** | `0111` | 1 | 1 | 1 | 0 | 0 | 0 | 0 |
| **8** | `1000` | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| **9** | `1001` | 1 | 1 | 1 | 1 | 0 | 1 | 1 |

### Lógica de Visualización Dinámica (Multiplexación)
Mediante un contador de 2 bits alimentado por un reloj de refresco (aprox. 60Hz a 1kHz), el sistema conmuta a alta velocidad entre los siguientes estados:

| Estado (Contador) | Display Activo (Habilitador) | Dato Enrutado al Decodificador | Visualización |
| :---: | :--- | :--- | :--- |
| `00` | **Display 1** (Izquierda) | Bit de Signo (`Sign`) | Símbolo `-` si es negativo, Apagado si es positivo. |
| `01` | **Display 2** (Centro) | `BCD_Decenas` | Dígito de las decenas (ej. '1'). |
| `10` | **Display 3** (Derecha) | `BCD_Unidades` | Dígito de las unidades (ej. '4'). |
| `11` | Ninguno (Reset/Espera) | `0000` | Display apagado para evitar "fantasmas". |



## 4.Imágenes de la simulación 
Lo que vemos a continuación es el hecho de tener dos entradas de 4 bits para generar la suma o la resta, respectivamente, que en este caso son A_do y B_do. Co_do sería el acarreo de salida. En des se guarda el valor de la operación matemática correspondiente a las decenas, y en uni el valor correspondiente a las unidades. mita es un registro de 13 bits que me permite crear un número que sirve para realizar la operación de "double dabble" (correr un bit y luego sumarle 5 cuando sea mayor a 4), para después asignarle a cada grupo de 4 bits las cantidades de decenas y unidades, respectivamente.

<img width="1262" height="712" alt="image" src="https://github.com/user-attachments/assets/f92cba8e-9ff9-4482-840d-81459d18ffe9" />


# 5. Codigos Implementados 

## 7_seg 
El módulo recibe como entrada num, que es ese número de 4 bits, y entrega como salida seg_out, una señal de 7 bits donde cada bit corresponde a uno de los segmentos del display (identificados como g, f, e, d, c, b, a). Internamente, usa una estructura case dentro de un bloque que se actualiza constantemente (combinacional), evaluando qué valor tiene num y, según eso, asignando el patrón exacto de segmentos que se deben encender o apagar para formar visualmente ese número en la pantalla

<img width="912" height="672" alt="image" src="https://github.com/user-attachments/assets/29f8f133-7ccc-4d8b-a42d-6b313d3d19aa" />

## double
Este módulo integra un sumador/restador de 4 bits (sumador_4_bits/restador_4) con un proceso de conversión binario-a-BCD usando el algoritmo "Double Dabble". Recibe dos números de 4 bits (A_do, B_do) y una señal sel_do que selecciona si se suma o se resta.

El resultado de la operación (So_do y el acarreo Co_do) se carga en un registro de 13 bits (mita). Luego, mediante un bloque combinacional, se realizan 5 desplazamientos sucesivos hacia la izquierda, y después de cada uno se verifica si el grupo de bits correspondiente (mita[8:5]) es mayor o igual a 5; si lo es, se le suma 3 (corrección típica del double dabble). Al final del proceso, los bits resultantes se separan en uni (unidades) y des (decenas), que luego se decodifican a 7 segmentos mediante uni_seg y des_seg para mostrarse en un display

<img width="1456" height="750" alt="image" src="https://github.com/user-attachments/assets/3c9ae53b-49f5-4f5a-8b54-c5bf361e24b2" />
<img width="1365" height="362" alt="image" src="https://github.com/user-attachments/assets/eeac3fc3-67b2-4a22-beef-642c4b560ebd" />
<img width="1380" height="772" alt="image" src="https://github.com/user-attachments/assets/6e115095-d7b8-4bd6-b0c1-41f4a005d557" />


## suma 
Este módulo implementa un sumador completo de 1 bit, la unidad básica para construir sumadores de más bits. Recibe tres entradas: A y B (los bits a sumar) y Ci (el acarreo de entrada, "carry in"). Produce dos salidas: S, el resultado de la suma, y Co, el acarreo de salida ("carry out").

<img width="1447" height="342" alt="image" src="https://github.com/user-attachments/assets/67a92ee2-04d9-401d-a547-8111b06e2bba" />

# Evidencia
https://youtube.com/shorts/jWe3wRK6m1o?feature=share


#conclusiones 
Desarrollar este sistema en FPGA nos dejó bastante claro que el reto no estaba tanto en la aritmética en sí sumar o restar 4 bits es relativamente sencillo, sino en todo lo que hay que resolver alrededor para que ese resultado se pueda "leer" en un display físico. El módulo de suma/resta fue la parte más intuitiva del proyecto, pero en cuanto empezamos a integrarlo con el Double Dabble entendimos por qué este algoritmo es tan usado en hardware: convertir binario a BCD sin usar un divisor nos obligó a pensar en términos de desplazamientos y comparaciones, algo que en software resolveríamos con una simple operación de módulo, pero que en hardware requiere describir paso a paso cada corrimiento y cada corrección de +3.

