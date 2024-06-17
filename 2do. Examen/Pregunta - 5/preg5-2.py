import numpy as np
from scipy.sparse import csr_matrix
from multiprocessing import Pool, cpu_count, freeze_support
import cv2

def multiplicarFila(args):
    indexFila, matriz1, matriz2 = args
    return indexFila, matriz1[indexFila, :].dot(matriz2)

def MultParallelSparce(matriz1, matriz2, numProcesadores=None):
    if numProcesadores is None:
        numProcesadores = cpu_count()  # Use all available CPU cores by default
    
    numFila = matriz1.shape[0]
    with Pool(processes=numProcesadores) as pool:
        resultado = pool.map(multiplicarFila, [(i, matriz1, matriz2) for i in range(numFila)])
    return resultado

if __name__ == '__main__':
    # Cargar las imágenes
    rutaImagenes = 'C:/Users/AnTrAx/Desktop/INFORMATICA/INF317/2do. Examen/Imagenes/'
    img1 = cv2.imread(rutaImagenes + 'uno.jpg', cv2.IMREAD_GRAYSCALE)
    img2 = cv2.imread(rutaImagenes + 'dos.jpg', cv2.IMREAD_GRAYSCALE)
    
    img1Resize = cv2.resize(img1, (1000, 1000))
    img2Resize = cv2.resize(img2, (1000, 1000))

    m1 = np.array(img1Resize)
    m2 = np.array(img2Resize)
    
    matriz1 = csr_matrix(m1)
    matriz2 = csr_matrix(m2)

    freeze_support()  # sin esto da en Windows
    resultado_paralelo = MultParallelSparce(matriz1, matriz2)

    fila = []
    colum = []
    data = []

    for res in resultado_paralelo:
        indexFila, resVector = res
        indicesNoCeros = resVector.nonzero()[1]
        for indexColum in indicesNoCeros:
            fila.append(indexFila)
            colum.append(indexColum)
            data.append(resVector[0, indexColum])

    filas, columnas = matriz1.shape[0], matriz2.shape[1]
    resultado_matriz = csr_matrix((data, (fila, colum)), shape=(filas, columnas))

    print("Forma de la matriz resultado:", resultado_matriz.shape)
    print("Numero de elementos no nulos en el resultado:", resultado_matriz.nnz)
    print("Algunos elementos no nulos del resultado:")
    print(resultado_matriz)
