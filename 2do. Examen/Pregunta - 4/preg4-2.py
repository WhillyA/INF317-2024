import numpy as np
from scipy.sparse import csr_matrix

filas, columnas = 1000, 1000
densidad = 0.01  
matriz1 = csr_matrix(np.random.rand(filas, columnas) < densidad, dtype=np.int8)
matriz2 = csr_matrix(np.random.rand(filas, columnas) < densidad, dtype=np.int8)

resultado = matriz1.dot(matriz2)

print(resultado)
print("Número de elementos no nulos en el resultado:", resultado.nnz)