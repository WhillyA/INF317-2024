from multiprocessing import Process, Queue

def generar_serie(inicio, fin, paso, cola):
    serie = []
    for i in range(inicio, fin, paso):
        serie.append(i)
    cola.put(serie)

def main():
    M = 4  # Número de procesadores
    N = 50 # Número de términos en la serie
    paso = 2  # Paso entre términos de la serie

    procesos = []
    resultados = Queue()

    # Calcular el rango de términos para cada proceso
    rango = (N // M) * paso
    residuo = N % M

    inicio = 2
    for i in range(M):
        fin = inicio + rango
        if i < residuo:
            fin += paso
        proceso = Process(target=generar_serie, args=(inicio, fin, paso, resultados))
        procesos.append(proceso)
        inicio = fin
    print("Rango de términos para cada proceso:", rango)
    print("Residuo:", residuo)

    # Iniciar los procesos
    for proceso in procesos:
        proceso.start()

    # Esperar a que todos los procesos terminen
    for proceso in procesos:
        proceso.join()

    # Obtener los resultados de las colas y concatenarlos
    serie_completa = []
    while not resultados.empty():
        serie_completa.extend(resultados.get())

    print("Serie completa:", serie_completa)

if __name__ == "__main__":
    main()
