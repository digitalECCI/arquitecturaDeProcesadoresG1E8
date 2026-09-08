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

* ![test_simulacion](./fig/prueba.md)

