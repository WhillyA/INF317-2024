import multiprocessing

def calcular_pi_parte(inicio, fin, resultado):
    suma = 0
    for i in range(inicio, fin):
        if i % 2 == 0:
            suma += 1 / (2 * i + 1)  # Sumar términos positivos
        else:
            suma -= 1 / (2 * i + 1)  # Restar términos negativos
    resultado.value += suma

def calcular_pi(num_partes):
    num_procesos = multiprocessing.cpu_count()
    procesos = []
    resultado = multiprocessing.Value('d', 0.0)

    for i in range(num_procesos):
        inicio = (num_partes // num_procesos) * i
        fin = (num_partes // num_procesos) * (i + 1)
        procesos.append(multiprocessing.Process(target=calcular_pi_parte, args=(inicio, fin, resultado)))

    for proceso in procesos:
        proceso.start()

    for proceso in procesos:
        proceso.join()

    pi = 4 * resultado.value
    return pi

if __name__ == "__main__":
    num_partes = 1000000
    pi = calcular_pi(num_partes)
    print("Valor aproximado de PI:", pi)
