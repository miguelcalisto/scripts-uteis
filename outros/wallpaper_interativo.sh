#!/usr/bin/env bash

wallpaper_dir="$HOME/Imagens/Wallpapers"
index_file="$HOME/.cache/current_wallpaper_index"

mkdir -p "$(dirname "$index_file")"

mapfile -t wallpapers < <(ls -1 "$wallpaper_dir" | grep -iE '\.(png|jpe?g|webp|svg)$')
num=${#wallpapers[@]}

    if [[ $num -eq 0 ]]; then
        echo "Nenhuma imagem encontrada."
        exit 1
    fi

    if [[ -f "$index_file" ]]; then
        index=$(cat "$index_file")
    else
        index=0
    fi

    apply_wallpaper() {
        local selected="$wallpaper_dir/${wallpapers[$index]}"
        feh --bg-scale "$selected"
        echo "$index" >"$index_file"
        printf "Wallpaper %02d de %02d: %s\n" "$((index + 1))" "$num" "${wallpapers[$index]}"
    }

clear
echo "Modo interativo de wallpapers"
echo "--------------------------------"
echo "1 → Próximo"
echo "2 → Anterior"
echo "r → Resetar índice"
echo "q → Sair"
echo ""

apply_wallpaper

while true; do
    echo -n "Escolha (1/2/q): "
    read -r choice

    case "$choice" in
        1)
            index=$(((index + 1) % num))
            apply_wallpaper
            ;;
        2)
            index=$(((index - 1 + num) % num))
            apply_wallpaper
            ;;
        q | Q)
            echo "Saindo..."
            exit 0
            ;;

        r | R)
            index=0
            apply_wallpaper
            ;;
        *)
            echo "Opção inválida."
            ;;
    esac
done
