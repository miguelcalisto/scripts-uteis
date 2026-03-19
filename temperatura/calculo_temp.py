import re
from statistics import mean
import os

arquivo_logs = "MEDIAS.txt"

try:
    if not os.path.exists(arquivo_logs):
        with open(arquivo_logs, "w", encoding="utf-8") as file:
            pass
        print(
                f"Arquivo '{arquivo_logs}' não encontrado. Um novo arquivo vazio foi criado."
                )
        print("Adicione dados no formato '00.00°C' e execute novamente.")
        exit(0)

    with open(arquivo_logs, "r", encoding="utf-8") as file:
        conteudo = file.read()

    temperaturas = [float(temp) for temp in re.findall(r"(\d+\.\d+)°C", conteudo)]

    if temperaturas:
        media_geral = mean(temperaturas)
        print(f"Média geral das temperaturas: {media_geral:.2f}°C")
    else:
        print("Nenhuma temperatura foi encontrada no arquivo.")

except Exception as e:
    print(f"Ocorreu um erro: {e}")
