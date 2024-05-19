#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

void generar_serie(int inicio, int fin, int paso, int rank, int size) {
    for (int i = inicio; i <= fin; i += paso) {
        printf("Proceso %d: %d\n", rank, i);
    }
}

int main(int argc, char *argv[]) {
    int rank, size;
    int n = 8; // Número de elementos en cada porción de la serie

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int total_elementos = n * size * 2; // Número total de elementos en la serie

    int inicio = rank * n * 2 + 2; // Inicio de la serie para el procesador actual
    int fin = inicio + (n * 2 - 2); // Fin de la serie para el procesador actual

    if (fin > total_elementos) {
        fin = total_elementos;
    }

    printf("Proceso %d: inicio = %d, fin = %d\n", rank, inicio, fin);

    generar_serie(inicio, fin, 2, rank, size);

    MPI_Finalize();

    return 0;
}
