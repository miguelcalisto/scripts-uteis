#!/usr/bin/env bash

wallpaper_dir="$HOME/Imagens/Wallpapers"

# Lista wallpapers válidos
mapfile -t wallpapers < <(ls -1S "$wallpaper_dir" | grep -iE '\.(png|jpe?g|webp|svg)$')
num=${#wallpapers[@]}

# Arquivo que salva índice
state_file="$HOME/.wallpaper_index"

# Se nunca foi salvo, inicia pelo dia do ano
if [[ ! -f "$state_file" ]]; then
    day_of_year=$(date +%j)
    index=$(( (day_of_year - 1) % num ))
    echo $index > "$state_file"
fi

index=$(cat "$state_file")

apply_wallpaper() {
    local idx=$1
    local selected="$wallpaper_dir/${wallpapers[$idx]}"
    feh --bg-scale "$selected"
    echo "Aplicado: $selected"
}

while true; do
    echo ""
    echo "=============================="
    echo "   CONTROLE DE WALLPAPER"
    echo "=============================="
    echo "Wallpaper atual: ${wallpapers[$index]}"
    echo ""
    echo "1 - Próximo"
    echo "2 - Anterior"
    echo "3 - Sair"
    echo -n "Escolha: "
    read -r choice

    case "$choice" in
        1)
            index=$(( (index + 1) % num ))
            apply_wallpaper "$index"
            ;;
        2)
            index=$(( (index - 1 + num) % num ))
            apply_wallpaper "$index"
            ;;
        3)
            echo "$index" > "$state_file"
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida!"
            ;;
    esac

    echo "$index" > "$state_file"
done
