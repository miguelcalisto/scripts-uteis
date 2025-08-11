#!/bin/bash

date_inicio=$(date +%H-%M)
arquivo="temperaturas_cpu.txt"
> "$arquivo"  # Limpa o arquivo

# Coleta por 3600 segundos (1 hora)
for ((i=0; i<3600; i++)); do
    # Pega temperaturas dos núcleos
    temperaturas=$(sensors | grep -E 'Core [0-9]:' | awk '{print $3}' | sed 's/+//;s/°C//')

    soma=0
    contador=0

    for temp in $temperaturas; do
        soma=$(echo "$soma + $temp" | bc)
        contador=$((contador + 1))
    done

    if [ $contador -gt 0 ]; then
        media=$(echo "scale=2; $soma / $contador" | bc)
        echo "$media" >> "$arquivo"
        echo "[$i] Média: $media°C"
    else
        echo "[$i] Nenhum núcleo encontrado."
    fi

    sleep 1
done
date=$(date +%H-%M)

hora_atual=$(date +%H:%M)
media=$(python3.11 media.py)
echo "$media log de  $hora_atual" >> ~/MEDIAS.txt

echo INCIO $date_inicio
echo FIM $date



