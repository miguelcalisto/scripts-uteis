#!/bin/bash

# Nome do arquivo da chave (pode ser customizado)
KEY_NAME="$HOME/.ssh/id_ed25519"

# E-mail para associar à chave (GitHub/GitLab usam isso)
read -p "Digite seu e-mail para a chave SSH: " email

# Verifica se a chave já existe
if [ -f "$KEY_NAME" ]; then
    echo "⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever."
    exit 1
fi

# Gera a chave SSH
echo "🔐 Gerando chave SSH..."
ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

# Inicia o ssh-agent
echo "🚀 Iniciando ssh-agent..."
eval "$(ssh-agent -s)"

# Adiciona a chave ao ssh-agent
ssh-add "$KEY_NAME"

# Copia a chave pública para a área de transferência (Linux com xclip/macOS com pbcopy)
if command -v xclip &> /dev/null; then
    cat "$KEY_NAME.pub" | xclip -selection clipboard
    echo "📋 Chave pública copiada para a área de transferência!"
elif command -v pbcopy &> /dev/null; then
    cat "$KEY_NAME.pub" | pbcopy
    echo "📋 Chave pública copiada para a área de transferência!"
else
    echo "ℹ️ Copie manualmente a chave pública abaixo:"
    echo
    cat "$KEY_NAME.pub"
    echo
fi

echo "✅ Chave SSH criada com sucesso!"
echo "👉 Agora adicione a chave pública na sua conta Git (GitHub/GitLab, etc)."

