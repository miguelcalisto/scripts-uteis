#!/usr/bin/env bash

GREEN='\033[0;32m'
RESET='\033[0m'

declare -A DIRS=(
    ["$HOME/.config"]="$HOME/Dotfiles/.config"
    ["$HOME/scripts"]="$HOME/Dotfiles/scripts"
    ["$HOME/SCRIPTS"]="$HOME/Dotfiles/SCRIPTS"
)

declare -A FILES=(
    ["$HOME/.bashrc"]="$HOME/Dotfiles/.bashrc"
    ["$HOME/.zshrc"]="$HOME/Dotfiles/.zshrc"
    ["$HOME/.vimrc"]="$HOME/Dotfiles/.vimrc"
    ["$HOME/.p10k.zsh"]="$HOME/Dotfiles/.p10k.zsh"
    ["$HOME/.tmux.conf"]="$HOME/Dotfiles/.tmux.conf"
)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

DIFF_LIST=$(mktemp)

comparar_dirs() {
    local DIR1="$1"
    local DIR2="$2"

    echo "🔍 Comparando diretórios: $DIR1 ↔ $DIR2 ..."
    echo

    find "$DIR1" -type f | while read -r file1; do
    file2="$DIR2${file1#$DIR1}"
    if [ -f "$file2" ]; then
        if ! diff -q "$file1" "$file2" >/dev/null; then
            echo "$file1|$file2" >>"$DIFF_LIST"
        fi
    fi
done
}

comparar_arquivos() {
    for file1 in "${!FILES[@]}"; do
        file2="${FILES[$file1]}"
        echo "🔍 Comparando arquivo: $file1 ↔ $file2 ..."
        if [ -f "$file1" ] && [ -f "$file2" ]; then
            if ! diff -q "$file1" "$file2" >/dev/null; then
                echo "$file1|$file2" >>"$DIFF_LIST"
            fi
        else
            echo "⚠️ Um dos arquivos não existe: $file1 ou $file2"
        fi
    done
}

for DIR1 in "${!DIRS[@]}"; do
    DIR2="${DIRS[$DIR1]}"
    comparar_dirs "$DIR1" "$DIR2"
done

comparar_arquivos
echo
echo -e "${GREEN}==================================================================================================${RESET}"
echo -e "${GREEN}==================================================================================================${RESET}"
echo "📜 Lista de arquivos diferentes:"
echo

if [ -s "$DIFF_LIST" ]; then
    cut -d'|' -f2 "$DIFF_LIST"
else
    echo "Nenhum arquivo diferente encontrado."
    rm "$DIFF_LIST"
    exit 0
fi

echo

while IFS='|' read -r file1 file2; do
    read -p "Deseja ver diferenças de $file2? [y/V/n/q] " resp </dev/tty
    case "$resp" in
        y | Y)
            echo -e "${GREEN}###############################${RESET}"
            echo -e "${BLUE}Diferenças em:${RESET} $file1 ↔ $file2"
            diff -u "$file1" "$file2" | sed 's/^/    /'
            echo
            ;;
        v | V)
            vimdiff "$file1" "$file2" </dev/tty
            ;;
        q | Q)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Pulando..."
            ;;
    esac
done <"$DIFF_LIST"

rm "$DIFF_LIST"
echo
echo "FIM"
