import os


def calcular_media_temperatura(arquivo):
    try:
        if not os.path.exists(arquivo):
            with open(arquivo, "w") as f:
                pass
            print(
                    f'Arquivo "{arquivo}" não encontrado. Um novo arquivo foi criado. Adicione temperaturas e execute novamente.'
                    )
            return

        with open(arquivo, "r") as f:
            temperaturas = [
                    float(linha.strip()) for linha in f.readlines() if linha.strip()
                    ]

        media_temperatura = sum(temperaturas) / len(temperaturas) if temperaturas else 0

        print(f"Média das temperaturas: {media_temperatura:.2f}°C")

    except ValueError:
        print(
                "O arquivo contém valores inválidos. Certifique-se de que todas as linhas têm números válidos."
                )
    except Exception as e:
        print(f"Ocorreu um erro: {e}")


arquivo = "temperaturas_cpu.txt"

calcular_media_temperatura(arquivo)
