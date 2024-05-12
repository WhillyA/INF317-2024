#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>

#define SEED 35791246

int main(int argc, char *argv[]) {
    int rank, size, i, N;
    double x, y, pi, pi_partial, start, end;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (argc != 2) {
        if (rank == 0) {
            fprintf(stderr, "Uso: %s <numero_de_puntos>\n", argv[0]);
        }
        MPI_Finalize();
        exit(EXIT_FAILURE);
    }

    if (sscanf(argv[1], "%d", &N) != 1 || N <= 0) {
        if (rank == 0) {
            fprintf(stderr, "El número de puntos debe ser un entero positivo.\n");
        }
        MPI_Finalize();
        exit(EXIT_FAILURE);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    start = MPI_Wtime();

    int count = 0; // Contador para puntos dentro del círculo

    srand(SEED + rank); // Inicializar la semilla de números aleatorios

    // Generar puntos aleatorios y contar cuántos caen dentro del círculo
    for (i = 0; i < N / size; i++) {
        x = (double)rand() / RAND_MAX;
        y = (double)rand() / RAND_MAX;
        if (x * x + y * y <= 1.0) {
            count++;
        }
    }

    // Calcular la aproximación parcial de PI para cada proceso
    pi_partial = 4.0 * count / (N / size);

    double total_pi; // Variable para almacenar el resultado de la reducción
    // Calcular el promedio de todas las aproximaciones parciales utilizando MPI_Reduce
    MPI_Reduce(&pi_partial, &total_pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        pi = total_pi / size; // Calcular PI promediando todas las aproximaciones parciales
        end = MPI_Wtime();
        printf("Valor aproximado de PI: %lf\n", pi);
        printf("Tiempo de ejecución: %lf segundos\n", end - start);
    }

    MPI_Finalize();

    return 0;
}
