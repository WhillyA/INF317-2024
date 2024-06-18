import multiprocessing as np
from multiprocessing import Pool
import math

def euler(inicial, final):
  s = 0
  for i in range(inicial+1, final):
    s += (1 / i**2)
  return s

if name=="main":
  limite = 1000000
  pool = Pool()
  parameters = [((i*limite),(limite*(i+1))) for i in range(np.cpu_count())]
  resultado = pool.starmap(euler, parameters)

  s = math.sqrt((resultado[0] + resultado[1])*6)
  print(s)
