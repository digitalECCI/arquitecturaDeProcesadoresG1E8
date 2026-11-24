#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// Mapa de memoria de periféricos (verificado en picosoc_noflash.v y top.v)
// ============================================================================
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data   (*(volatile uint32_t*)0x02000008)
#define reg_leds        (*(volatile uint32_t*)0x03000000)
#define reg_switches    (*(volatile uint32_t*)0x03000004)

// Frecuencia de reloj DE10-Lite: 50 MHz | Baudrate: 115200 -> 50000000 / 115200 = 434
#define CLK_FREQ  50000000
#define BAUD_RATE 115200

// ============================================================================
// Funciones básicas de UART y utilidades (bare-metal, sin libc)
// ============================================================================
static void uart_putchar(char c)
{
    if (c == '\n')
        reg_uart_data = '\r';
    reg_uart_data = c;
}

static void uart_puts(const char *s)
{
    while (*s)
        uart_putchar(*s++);
}

static char uart_getchar(void)
{
    int32_t c = -1;
    while (c == -1)
        c = (int32_t)reg_uart_data;
    return (char)c;
}

static void uart_put_int(int32_t val)
{
    char buf[12];
    int i = 0;
    if (val == 0) {
        uart_putchar('0');
        return;
    }
    if (val < 0) {
        uart_putchar('-');
        val = -val;
    }
    while (val > 0) {
        buf[i++] = '0' + (val % 10);
        val /= 10;
    }
    while (i > 0)
        uart_putchar(buf[--i]);
}

static void delay_ms(uint32_t ms)
{
    // Retardo aproximado por software a 50 MHz
    for (uint32_t i = 0; i < ms; i++) {
        for (volatile uint32_t j = 0; j < 2500; j++);
    }
}

static bool str_eq(const char *a, const char *b)
{
    while (*a && *b) {
        if (*a++ != *b++) return false;
    }
    return (*a == '\0' && *b == '\0');
}

static const char *skip_spaces(const char *p)
{
    while (*p == ' ' || *p == '\t') p++;
    return p;
}

static const char *next_token(const char *p, char *tok, int max_len)
{
    p = skip_spaces(p);
    int i = 0;
    while (*p && *p != ' ' && *p != '\t' && i < max_len - 1) {
        tok[i++] = *p++;
    }
    tok[i] = '\0';
    return p;
}

// Soporta enteros decimales y hexadecimales (ej. 10, -5, 0x0A)
static bool parse_int(const char *s, int32_t *out)
{
    if (!s || *s == '\0') return false;
    int sign = 1;
    if (*s == '-') {
        sign = -1;
        s++;
    }
    if (*s == '\0') return false;

    int32_t res = 0;
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s += 2;
        if (*s == '\0') return false;
        while (*s) {
            char c = *s++;
            res <<= 4;
            if (c >= '0' && c <= '9') res |= (c - '0');
            else if (c >= 'a' && c <= 'f') res |= (c - 'a' + 10);
            else if (c >= 'A' && c <= 'F') res |= (c - 'A' + 10);
            else return false;
        }
    } else {
        while (*s) {
            char c = *s++;
            if (c < '0' || c > '9') return false;
            res = res * 10 + (c - '0');
        }
    }
    *out = res * sign;
    return true;
}

// ============================================================================
// Intérprete de comandos
// ============================================================================
static void process_command(const char *line)
{
    char cmd[16], arg1[16], arg2[16], arg3[16];
    const char *p = next_token(line, cmd, sizeof(cmd));

    if (cmd[0] == '\0')
        return;

    // 1. help
    if (str_eq(cmd, "help")) {
        uart_puts("Comandos disponibles:\n");
        uart_puts("  help                - Muestra esta ayuda\n");
        uart_puts("  led <n> <on|off>    - Enciende o apaga el LED n (0..3)\n");
        uart_puts("  leds <valor>        - Asigna valor a LEDs (ej. leds 0x0A o leds 5)\n");
        uart_puts("  sw                  - Lee el estado de los 4 switches\n");
        uart_puts("  blink <n> <veces>   - Parpadea el LED n la cantidad de veces\n");
        uart_puts("  calc <a> <op> <b>   - Opera dos enteros (+ - * /)\n");
        uart_puts("  kitt <ciclos>       - Secuencia Auto Fantastico en LEDs\n");
    }
    // 2. led <n> <on|off>
    else if (str_eq(cmd, "led")) {
        p = next_token(p, arg1, sizeof(arg1));
        p = next_token(p, arg2, sizeof(arg2));
        int32_t n;
        if (!parse_int(arg1, &n) || n < 0 || n > 3) {
            uart_puts("Error: LED invalido (use 0..3)\n");
            return;
        }
        if (str_eq(arg2, "on")) {
            reg_leds |= (1 << n);
            uart_puts("ok\n");
        } else if (str_eq(arg2, "off")) {
            reg_leds &= ~(1 << n);
            uart_puts("ok\n");
        } else {
            uart_puts("Uso: led <0..3> <on|off>\n");
        }
    }
    // 3. leds <valor>
    else if (str_eq(cmd, "leds")) {
        next_token(p, arg1, sizeof(arg1));
        int32_t val;
        if (!parse_int(arg1, &val)) {
            uart_puts("Uso: leds <valor> (ej. leds 0x0F)\n");
            return;
        }
        reg_leds = (uint32_t)(val & 0x0F);
        uart_puts("ok\n");
    }
    // 4. sw
    else if (str_eq(cmd, "sw")) {
        uint32_t s = reg_switches & 0x0F;
        uart_puts("switches = 0b");
        for (int i = 3; i >= 0; i--) {
            uart_putchar((s & (1 << i)) ? '1' : '0');
        }
        uart_puts(" (");
        uart_put_int((int32_t)s);
        uart_puts(")\n");
    }
    // 5. blink <n> <veces>
    else if (str_eq(cmd, "blink")) {
        p = next_token(p, arg1, sizeof(arg1));
        p = next_token(p, arg2, sizeof(arg2));
        int32_t n, times;
        if (!parse_int(arg1, &n) || n < 0 || n > 3 || !parse_int(arg2, &times) || times <= 0) {
            uart_puts("Uso: blink <0..3> <veces>\n");
            return;
        }
        for (int32_t i = 0; i < times; i++) {
            reg_leds |= (1 << n);
            delay_ms(200);
            reg_leds &= ~(1 << n);
            delay_ms(200);
        }
        uart_puts("ok\n");
    }
    // 6. calc <a> <op> <b>
    else if (str_eq(cmd, "calc")) {
        p = next_token(p, arg1, sizeof(arg1));
        p = next_token(p, arg2, sizeof(arg2));
        p = next_token(p, arg3, sizeof(arg3));
        int32_t a, b, res = 0;
        if (!parse_int(arg1, &a) || !parse_int(arg3, &b) || arg2[1] != '\0') {
            uart_puts("Uso: calc <a> <+|-|*|/> <b>\n");
            return;
        }
        char op = arg2[0];
        if (op == '+') res = a + b;
        else if (op == '-') res = a - b;
        else if (op == '*') res = a * b;
        else if (op == '/') {
            if (b == 0) {
                uart_puts("Error: division por cero\n");
                return;
            }
            res = a / b;
        } else {
            uart_puts("Operador invalido (use + - * /)\n");
            return;
        }
        uart_put_int(a);
        uart_putchar(' ');
        uart_putchar(op);
        uart_putchar(' ');
        uart_put_int(b);
        uart_puts(" = ");
        uart_put_int(res);
        uart_putchar('\n');
    }
    // 7. Comando propio del grupo: kitt <ciclos> (secuencia Auto Fantástico)
    else if (str_eq(cmd, "kitt")) {
        next_token(p, arg1, sizeof(arg1));
        int32_t cycles = 3;
        if (arg1[0] != '\0' && (!parse_int(arg1, &cycles) || cycles <= 0)) {
            uart_puts("Uso: kitt [ciclos]\n");
            return;
        }
        uint32_t prev = reg_leds;
        for (int32_t c = 0; c < cycles; c++) {
            for (int i = 0; i < 4; i++) {
                reg_leds = (1 << i);
                delay_ms(100);
            }
            for (int i = 2; i >= 1; i--) {
                reg_leds = (1 << i);
                delay_ms(100);
            }
        }
        reg_leds = prev;
        uart_puts("ok\n");
    }
    else {
        uart_puts("Comando desconocido. Escriba 'help'\n");
    }
}

// ============================================================================
// Función principal
// ============================================================================
void main(void)
{
    reg_uart_clkdiv = CLK_FREQ / BAUD_RATE;
    reg_leds = 0x05; // Parpadeo inicial de prueba visual en LEDs al arrancar
    delay_ms(150);
    reg_leds = 0x00;

    uart_puts("\n=== picoSoC Shell - DE10-Lite ===\n");
    uart_puts("Escriba 'help' para ver los comandos.\n");

    char line[64];
    int pos = 0;

    while (1) {
        uart_puts("> ");
        pos = 0;

        while (1) {
            char c = uart_getchar();
            if (c == '\r' || c == '\n') {
                uart_putchar('\n');
                line[pos] = '\0';
                process_command(line);
                break;
            } else if ((c == '\b' || c == 127) && pos > 0) {
                pos--;
                uart_puts("\b \b");
            } else if (c >= 32 && c < 127 && pos < (int)sizeof(line) - 1) {
                line[pos++] = c;
                uart_putchar(c);
            }
        }
    }
}