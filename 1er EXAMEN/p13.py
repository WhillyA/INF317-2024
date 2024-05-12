import multiprocessing

def fibonacci(n, memo={}):
    if n <= 1:
        return n
    if n not in memo:
        memo[n] = fibonacci(n-1, memo) + fibonacci(n-2, memo)
    return memo[n]

def calculate_fibonacci_range(start, end, results):
    results.extend([fibonacci(i) for i in range(start, end)])

def main():
    num_terms = 50
    num_processors = multiprocessing.cpu_count()

    # Calcular la cantidad de términos por procesador
    terms_per_processor = num_terms // num_processors
    remainder = num_terms % num_processors

    # Crear los procesos
    processes = []
    results = multiprocessing.Manager().list()  # Lista compartida para almacenar los resultados
    for i in range(num_processors):
        start = i * terms_per_processor
        end = start + terms_per_processor
        if i == num_processors - 1:
            end += remainder  # Añadir el resto al último procesador
        process = multiprocessing.Process(target=calculate_fibonacci_range, args=(start, end, results))
        processes.append(process)
        
    # Iniciar los procesos
    for process in processes:
        process.start()
        
    # Esperar a que todos los procesos terminen
    for process in processes:
        process.join()
        
    # Imprimir los resultados
    print("Fibonacci sequence:", results)

if __name__ == "__main__":
    main()
