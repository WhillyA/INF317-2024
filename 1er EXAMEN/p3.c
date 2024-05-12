#include <stdio.h>
#include <omp.h>

// Función para multiplicar dos números utilizando sumas
int multiplicacion(int a, int b) {
    int resultado = 0;
    int i; // Declaramos 'i' fuera de la directiva OpenMP
    #pragma omp parallel for reduction(+:resultado) private(i)
    for (i = 0; i < b; i++) {
        int procesadorActivo = omp_get_thread_num();
        printf("Procesador activo en hilo %d - Cálculo: %d * %d = %d\n", procesadorActivo, a, i, a * i);
        resultado += a;
    }
    return resultado;
}

// Función para dividir dos números utilizando restas
int division(int a, int b) {
    if (b == 0) {
        printf("Error: División por cero\n");
        return 0;
    }
    int resultado = 0;
    int temp = a;
    int procesadorActivo; // Declaramos 'procesadorActivo' fuera de la directiva OpenMP
    #pragma omp parallel private(procesadorActivo)
    {
        procesadorActivo = omp_get_thread_num();
        #pragma omp single
        while (temp >= b) {
            temp -= b;
            resultado++;
            printf("Procesador activo en hilo %d - Cálculo: %d - %d = %d\n", procesadorActivo, temp + b, b, temp);
        }
    }
    return resultado;
}

int main() {
    int num1 = 1500, num2 = 42;

    // Multiplicación en base a sumas
    printf("Multiplicación: %d\n", multiplicacion(num1, num2));

    // División en base a restas
    printf("División: %d\n", division(num1, num2));

    return 0;
}
