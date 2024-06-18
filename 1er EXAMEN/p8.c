#include <stdio.h>
#include <omp.h>

int main() {
    int N, M;

    printf("Introduce el número de términos (N): ");
    scanf("%d", &N);
    printf("Introduce el número de procesadores (M): ");
    scanf("%d", &M);

    int serie[N];

    // # de hilos en OpenMP
    omp_set_num_threads(M);

    int i;

    #pragma omp parallel shared(N, serie) private(i)
    {
        #pragma omp for
        for (i = 0; i < N; i++) {
            int id = omp_get_thread_num();
            serie[i] = (i + 1) * 2;
            #pragma omp critical
            {
                printf("Procesador %d calculó el término %d: %d\n", id, i, serie[i]);
            }
        }
    }

    printf("Serie generada: ");
    for (i = 0; i < N; i++) {
        printf("%d ", serie[i]);
    }
    printf("\n");

    return 0;
}

