import numpy as np
from scipy.sparse import csr_matrix
from multiprocessing import Pool, cpu_count, freeze_support

def multiplicarFila(args):
    indexFila, matriz1, matriz2 = args
    return indexFila, matriz1[indexFila, :].dot(matriz2)

def MultParallelSparce(matriz1, matriz2, numProcesadores=None):
    if numProcesadores is None:
        numProcesadores = cpu_count()  # usa todos los procesadores disponibles
    
    numFila = matriz1.shape[0]
    with Pool(processes=numProcesadores) as pool:
        resultado = pool.map(multiplicarFila, [(i, matriz1, matriz2) for i in range(numFila)])
    return resultado

if __name__ == '__main__':
    
    filas, columnas = 1000, 1000
    densidad = 0.01  

    matriz1 = csr_matrix(np.random.rand(filas, columnas) < densidad, dtype=np.int8)
    matriz2 = csr_matrix(np.random.rand(filas, columnas) < densidad, dtype=np.int8)

   
    freeze_support()  # sin esto no da en windows
    resultado_paralelo = MultParallelSparce(matriz1, matriz2)

    fila = []
    colm = []
    data = []

    for res in resultado_paralelo:
        indexFila, resVector = res
        indicesNoCeros = resVector.nonzero()[1]
        for indexColumna in indicesNoCeros:
            fila.append(indexFila)
            colm.append(indexColumna)
            data.append(resVector[0, indexColumna])

    resultado_matriz = csr_matrix((data, (fila, colm)), shape=(filas, columnas))

    print("Forma de la matriz resultado:", resultado_matriz.shape)
    print("Número de elementos no nulos en el resultado:", resultado_matriz.nnz)
    print("Algunos elementos no nulos del resultado:")
    print(resultado_matriz)
