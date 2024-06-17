import cv2
import numpy as np

#subir imagenes
rutaImagenes = 'C:/Users/AnTrAx/Desktop/INFORMATICA/INF317/2do. Examen/Imagenes/'
img1 = cv2.imread(rutaImagenes + 'uno.jpg')
img2 = cv2.imread(rutaImagenes + 'tres.jpg')
img3 = cv2.imread(rutaImagenes + 'cinco.jpg')
img1=cv2.resize(img1, (200 , 200))
img2=cv2.resize(img2, (200, 200))
img3=cv2.resize(img3, (200, 200))
# Sumar
alpha = 0.5  
beta = 1 - alpha  
suma = cv2.addWeighted(img1, alpha, img2, beta, 0)

# Restar
#resta = cv2.hconcat([img2, img1])
resta = cv2.absdiff(img3, img2)
#resta = cv2.subtract(img1, img3)

# Mostrar
cv2.imshow('imagen1', img1)
cv2.imshow('imagen2', img2)
cv2.imshow('imagen3', img3)
cv2.imshow('Suma', suma)
cv2.imshow('Resta', resta)
cv2.waitKey(0)
cv2.destroyAllWindows()
