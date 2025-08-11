import os

# Função para calcular a média das temperaturas
def calcular_media_temperatura(arquivo):
    try:
        # Verifica se o arquivo existe; se não, cria um vazio
        if not os.path.exists(arquivo):
            with open(arquivo, 'w') as f:
                pass  # Cria o arquivo vazio
            print(f'Arquivo "{arquivo}" não encontrado. Um novo arquivo foi criado. Adicione temperaturas e execute novamente.')
            return

        # Abre o arquivo para leitura
        with open(arquivo, 'r') as f:
            # Lê todas as linhas e converte cada linha em float
            temperaturas = [float(linha.strip()) for linha in f.readlines() if linha.strip()]
        
        # Calcula a média das temperaturas
        media_temperatura = sum(temperaturas) / len(temperaturas) if temperaturas else 0
        
        # Exibe o resultado
        print(f'Média das temperaturas: {media_temperatura:.2f}°C')
        
    except ValueError:
        print("O arquivo contém valores inválidos. Certifique-se de que todas as linhas têm números válidos.")
    except Exception as e:
        print(f'Ocorreu um erro: {e}')

# Nome do arquivo com as temperaturas
arquivo = 'temperaturas_cpu.txt'

# Chama a função para calcular e exibir a média
calcular_media_temperatura(arquivo)

