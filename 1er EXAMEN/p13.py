import multiprocessing as np
from multiprocessing import Pool
import math

def fibo(inicial, final):
  v = []
  for i in range(inicial, final):
    p1 = ((1/math.sqrt(5))* ((1 + math.sqrt(5))/2)  i)
    p2 = ((1/math.sqrt(5))* ((1 - math.sqrt(5))/2)  i)
    pt = round(p1 - p2)
    v.append(pt)
  return v

if name=="main":
  limite = 500
  parameters = [((i*limite),(limite*(i+1))) for i in range(np.cpu_count())]
  print(parameters)


  pool = Pool()
  resultado = pool.starmap(fibo, parameters)
  for i in resultado:
    print(i)
