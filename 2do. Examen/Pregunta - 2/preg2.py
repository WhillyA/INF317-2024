
import cv2
import numpy as np
from scipy.sparse import csr_matrix

rutaImagenes = 'C:/Users/AnTrAx/Desktop/INFORMATICA/INF317/2do. Examen/Imagenes/'
img1 = cv2.imread(rutaImagenes + 'uno.jpg', cv2.IMREAD_GRAYSCALE)
img2 = cv2.imread(rutaImagenes + 'dos.jpg', cv2.IMREAD_GRAYSCALE)

# img2_resized = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
img1=cv2.resize(img1, (500, 500))
img2=cv2.resize(img2, (500, 500))

matriz = np.array(img1) + np.array(img2)

csr = csr_matrix(matriz)
print(csr)