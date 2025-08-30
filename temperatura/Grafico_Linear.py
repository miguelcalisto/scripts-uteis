import matplotlib.pyplot as plt
import re

# Nome do arquivo
arquivo = "MEDIAS.txt"

# Listas para armazenar os dados
horarios = []
temperaturas = []

try:
    with open(arquivo, "r") as f:
        linhas = f.readlines()

    # Extrai temperatura e horário completo
    for linha in linhas:
        match = re.search(r"Média das temperaturas:\s*([\d.]+)°C log de\s+(.+)", linha)
        if match:
            temperatura = float(match.group(1))
            horario = match.group(2).strip()  # Captura tudo após "log de"

            temperaturas.append(temperatura)
            horarios.append(horario)
        else:
            print("Linha ignorada:", linha.strip())

    if not horarios or not temperaturas:
        print("Nenhum dado de temperatura encontrado no arquivo.")
    else:
        # Garante que os dados estão ordenados pelo horário (alfabeticamente)
        horarios, temperaturas = zip(*sorted(zip(horarios, temperaturas)))

        # Gráfico
        plt.figure(figsize=(10, 5))
        plt.plot(horarios, temperaturas, marker='o', linestyle='-', color='blue')
        plt.xlabel("Horário do Log")
        plt.ylabel("Temperatura Média (°C)")
        plt.title("Variação das Temperaturas Médias da CPU ao Longo do Tempo")
        plt.grid(True)
        plt.xticks(rotation=45)  # Rotaciona para melhor visualização
        plt.tight_layout()
        plt.show()

except FileNotFoundError:
    print(f"Arquivo '{arquivo}' não encontrado.")
except Exception as e:
    print(f"Ocorreu um erro: {e}")

