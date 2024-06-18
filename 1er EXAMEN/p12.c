#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define N 10  // # Fibonaccis

int fibonacci(int n) {
    if (n <= 1)
        return n;
    else
        return fibonacci(n - 1) + fibonacci(n - 2);
}

int main(int argc, char **argv) {
    int rango, tamaño;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rango);
    MPI_Comm_size(MPI_COMM_WORLD, &tamaño);

    if (tamaño < 2) {
        printf("Se necesitan al menos 2 procesos: un maestro y al menos un esclavo.\n");
        MPI_Finalize();
        return EXIT_FAILURE;
    }

    if (rango == 0) {
        printf("Secuencia de Fibonacci:\n");

        for (int i = 0; i < N; i++) {
            int resultado;
            MPI_Recv(&resultado, 1, MPI_INT, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            printf("%d ", resultado);
        }
        printf("\n");
    } else {
        for (int i = 0; i < N; i++) {
            int resultado = fibonacci(i);
            MPI_Send(&resultado, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
        }
    }

    MPI_Finalize();
    return EXIT_SUCCESS;
}


