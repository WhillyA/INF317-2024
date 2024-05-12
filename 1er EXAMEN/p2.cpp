#include <iostream>

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
        std::cout << "Error: División por cero\n";
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
    
    std::cout << "Suma: " << suma(&num1, &num2) << std::endl;
    std::cout << "Resta: " << resta(&num1, &num2) << std::endl;
    std::cout << "Multiplicación: " << multiplicacion(&num1, &num2) << std::endl;
    
    if (num2 != 0) {
        std::cout << "División: " << division(&num1, &num2) << std::endl;
    } else {
        std::cout << "No se puede dividir por cero." << std::endl;
    }

    return 0;
}
