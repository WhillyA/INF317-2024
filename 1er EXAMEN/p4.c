#include <stdio.h>
#include <omp.h>

#define N 4 // Tamaño de la matriz y el vector

// Función para multiplicar una matriz NxN por un vector de dimensión N
void multiplicacion_matriz_vector(int matriz[N][N], int vector[N], int resultado[N]) {
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        // Cada hilo calcula el producto interno de una fila de la matriz con el vector
        int temp = 0;
        int procesadorActivo = omp_get_thread_num(); // Obtener el número del procesador activo
        for (int j = 0; j < N; j++) {
            temp += matriz[i][j] * vector[j];
        }
        // Almacenar el resultado en paralelo usando una reducción
        #pragma omp atomic
        resultado[i] += temp;
        printf("Procesador activo en hilo %d - Cálculo de fila %d\n", procesadorActivo, i);
    }
}

int main() {
    int matriz[N][N] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12},
        {13, 14, 15, 16}
    };

    int vector[N] = {1, 2, 3, 4};
    int resultado[N] = {0}; // Inicializar el resultado a cero

    // Mostrar la matriz y el vector
    printf("Matriz:\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", matriz[i][j]);
        }
        printf("\n");
    }

    printf("\nVector:\n");
    for (int i = 0; i < N; i++) {
        printf("%d\n", vector[i]);
    }
    printf("\n");

    // Multiplicación de la matriz por el vector
    multiplicacion_matriz_vector(matriz, vector, resultado);

    // Imprimir el resultado
    printf("Resultado:\n");
    for (int i = 0; i < N; i++) {
        printf("%d ", resultado[i]);
    }
    printf("\n");

    return 0;
}
