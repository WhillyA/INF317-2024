#include <stdio.h>
#include <mpi.h>

int fibonacci(int n) {
    if (n <= 1)
        return n;
    else
        return fibonacci(n-1) + fibonacci(n-2);
}

int main(int argc, char *argv[]) {
    int rank, size, term, fib_term;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        // Proceso maestro
        for (int i = 2; i < size; i++) {
            // Solicita término de Fibonacci al esclavo i
            MPI_Send(&i, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
        }

        // Imprime el término de Fibonacci calculado localmente
        printf("Fibonacci(0) = %d\n", fibonacci(0));
        printf("Fibonacci(1) = %d\n", fibonacci(1));

        // Recibe y muestra los términos de Fibonacci de los esclavos
        for (int i = 2; i < size; i++) {
            MPI_Recv(&term, 1, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            printf("Fibonacci(%d) = %d\n", i, term);
        }
    } else {
        // Procesos esclavos
        MPI_Recv(&term, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        fib_term = fibonacci(term);
        MPI_Send(&fib_term, 1, MPI_INT, 0, 0, MPI_COMM_WORLD); // Enviar el término calculado al proceso maestro
    }

    MPI_Finalize();
    return 0;
}
