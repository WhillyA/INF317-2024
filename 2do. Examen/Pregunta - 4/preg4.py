import cv2
import numpy as np
from scipy.sparse import csr_matrix

rutaImagenes = 'C:/Users/AnTrAx/Desktop/INFORMATICA/INF317/2do. Examen/Imagenes/'
img1 = cv2.imread(rutaImagenes + 'uno.jpg', cv2.IMREAD_GRAYSCALE)
img2 = cv2.imread(rutaImagenes + 'dos.jpg', cv2.IMREAD_GRAYSCALE)

# img2_resized = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
img1=cv2.resize(img1, (1000, 1000))
img2=cv2.resize(img2, (1000, 1000))

#matriz = np.array(img1) + np.array(img2)

m1 = np.array(img1)
m2 = np.array(img2)

csr1 = csr_matrix(m1)
csr2 = csr_matrix(m2)

mul = csr1.dot(csr2)

print(mul)
print("Numero de elementos no nulos en el resultado:", mul.nnz)
