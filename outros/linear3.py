import plotly.graph_objects as go
import re
from datetime import datetime

meses_pt = {
    'jan': 1, 'fev': 2, 'mar': 3, 'abr': 4, 'mai': 5, 'jun': 6,
    'jul': 7, 'ago': 8, 'set': 9, 'out': 10, 'nov': 11, 'dez': 12
}

arquivo = "MEDIAS.txt"

horarios = []
temperaturas = []

try:
    with open(arquivo, "r") as f:
        linhas = f.readlines()

    for linha in linhas:
        match = re.search(r"Média das temperaturas:\s*([\d.]+)°C log de\s+(.+)", linha)
        if match:
            temperatura = float(match.group(1))
            data_str = match.group(2).strip()

            partes = data_str.split()
            if len(partes) >= 5:
                dia = partes[1]
                mes_str = partes[2].lower()
                ano = partes[3]
                hora = partes[4]

                mes = meses_pt.get(mes_str)
                if mes is None:
                    print(f"Mês inválido: {mes_str}")
                    continue

                data_formatada = f"{dia} {mes:02d} {ano} {hora}"
                try:
                    horario = datetime.strptime(data_formatada, "%d %m %Y %H:%M:%S")
                except ValueError as e:
                    print(f"Erro ao converter data: {data_formatada} ({e})")
                    continue
            else:
                print(f"Formato de data inesperado: {data_str}")
                continue

            temperaturas.append(temperatura)
            horarios.append(horario)
        else:
            print("Linha ignorada:", linha.strip())

    if not horarios or not temperaturas:
        print("Nenhum dado de temperatura encontrado no arquivo.")
    else:
        horarios, temperaturas = zip(*sorted(zip(horarios, temperaturas)))
        horarios_str = [dt.strftime("%d/%m %H:%M") for dt in horarios]

        fig = go.Figure()
        fig.add_trace(go.Scatter(x=horarios_str, y=temperaturas, mode='lines+markers', name='Temperatura'))

        fig.update_layout(
            title="Variação das Temperaturas Médias da CPU ao Longo do Tempo",
            xaxis_title="Horário do Log",
            yaxis_title="Temperatura Média (°C)",
            xaxis=dict(
                rangeslider=dict(visible=True),  # barra de scroll horizontal
                type="category"
            ),
            template="plotly_dark"
        )

        fig.show()

except FileNotFoundError:
    print(f"Arquivo '{arquivo}' não encontrado.")
except Exception as e:
    print(f"Ocorreu um erro: {e}")
