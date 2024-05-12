#include <stdio.h>
#include <omp.h>

#define N 10 // Número de términos de la serie
#define M 2  // Número de vectores (procesadores)

int main() {
    int series[M][N]; // Matriz para almacenar las series generadas por cada hilo

    #pragma omp parallel num_threads(M)
    {
        int tid = omp_get_thread_num(); // Obtener el ID del hilo
        int inicio = tid * N;           // Calcular el índice de inicio para este hilo

        // Generar la serie en este hilo
        for (int i = 0; i < N; i++) {
            series[tid][i] = (inicio + i + 1) * 2;
        }
    }

    // Imprimir las series generadas
    printf("Series generadas:\n");
    for (int i = 0; i < M; i++) {
        printf("Procesador %d:", i);
        for (int j = 0; j < N; j++) {
            printf(" %d", series[i][j]);
        }
        printf("\n");
    }

    return 0;
}
