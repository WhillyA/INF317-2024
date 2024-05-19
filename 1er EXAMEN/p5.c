#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define N 4 // Tamaño de la matriz y el vector

// Función para realizar la multiplicación de una matriz NxN por un vector de dimensión N
void multiplicacion_matriz_vector(int matriz[N][N], int vector[N], int resultado[N], int inicio, int fin, int rank) {
    for (int i = inicio; i < fin; i++) {
        resultado[i] = 0;
        for (int j = 0; j < N; j++) {
            resultado[i] += matriz[i][j] * vector[j];
        }
        printf("Proceso %d: Resultado parcial para fila %d: %d\n", rank, i, resultado[i]);
    }
}

int main(int argc, char *argv[]) {
    int rank, size;
    int matriz[N][N] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {9, 10, 11, 12},
        {13, 14, 15, 16}
    };
    int vector[N] = {1, 2, 3, 4};
    int resultado[N] = {0}; // Inicializar el resultado a cero
    int resultado_parcial[N] = {0};

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Calcular el tamaño de cada bloque de filas de la matriz para cada proceso
    int tam_bloque = N / size;
    int inicio = rank * tam_bloque;
    int fin = inicio + tam_bloque;

    // Multiplicación de la matriz por el vector
    multiplicacion_matriz_vector(matriz, vector, resultado_parcial, inicio, fin, rank);

    // Combinar los resultados parciales en el proceso raíz (rank 0)
    MPI_Gather(&resultado_parcial[inicio], tam_bloque, MPI_INT, resultado, tam_bloque, MPI_INT, 0, MPI_COMM_WORLD);

    // Imprimir el resultado en el proceso raíz
    if (rank == 0) {
        printf("\nResultado completo:\n");
        for (int i = 0; i < N; i++) {
            printf("%d ", resultado[i]);
        }
        printf("\n");
    }
    MPI_Finalize();

    return 0;
}
