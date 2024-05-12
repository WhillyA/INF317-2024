#include <stdio.h>

// Función para sumar dos números
int suma(int *a, int *b) {
    return *a + *b;
}

// Función para restar dos números
int resta(int *a, int *b) {
    return *a - *b;
}

// Función para multiplicar dos números
int multiplicacion(int *a, int *b) {
    int resultado = 0;
    for (int i = 0; i < *b; i++) {
        resultado += *a;
    }
    return resultado;
}

// Función para dividir dos números
float division(int *a, int *b) {
    if (*b == 0) {
        printf("Error: División por cero\n");
        return 0;
    }
    float resultado = 0;
    float temp = *a;
    while (temp >= *b) {
        temp -= *b;
        resultado++;
    }
    return resultado;
}

int main() {
    // Ejemplo de uso de las funciones
    int num1 = 5, num2 = 2;
    
    printf("Suma: %d\n", suma(&num1, &num2));
    printf("Resta: %d\n", resta(&num1, &num2));
    printf("Multiplicación: %d\n", multiplicacion(&num1, &num2));
    
    if (num2 != 0) {
        printf("División: %.2f\n", division(&num1, &num2));
    } else {
        printf("No se puede dividir por cero.\n");
    }

    return 0;
}
