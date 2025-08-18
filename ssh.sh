#!/bin/bash

echo "use :git remote set-url origin git@github.com:user/rep.git"

KEY_NAME="$HOME/.ssh/id_ed25519"
read -p "Digite seu e-mail para a chave SSH: " email

if [ -f "$KEY_NAME" ]; then
    echo "⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever."
    exit 1
fi

echo "🔐 Gerando chave SSH..."
ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

echo "🧠 Verificando ssh-agent..."
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "🚀 ssh-agent não está rodando. Iniciando..."
    eval "$(ssh-agent -s)"
else
    echo "✅ ssh-agent já está em execução."
fi

if ssh-add -l 2>/dev/null | grep -q "$KEY_NAME"; then
    echo "🔐 A chave já está adicionada ao ssh-agent."
else
    echo "➕ Adicionando chave ao ssh-agent..."
    ssh-add "$KEY_NAME"
fi

# Copia chave para área de transferência
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

read -p "Deseja configurar seu nome e e-mail global no Git? (s/n): " configure_git
if [[ "$configure_git" =~ ^[sS]$ ]]; then
    read -p "Digite seu nome completo para o Git: " git_name
    git config --global user.name "$git_name"
    git config --global user.email "$email"
    echo "✅ Git configurado globalmente com:"
    echo "   🧑 Nome:  $(git config --global user.name)"
    echo "   📧 E-mail: $(git config --global user.email)"
    git config --global --list
fi

# Testa a conexão com o GitHub
echo "🌐 Testando conexão com o GitHub..."
ssh_output=$(ssh -T git@github.com 2>&1)

if echo "$ssh_output" | grep -q "successfully authenticated"; then
    echo "✅ Conexão estabelecida com sucesso! Sua chave SSH está funcionando. 🎉"
else
    echo "⚠️ Não foi possível se conectar ao GitHub via SSH."
    echo "🔍 Verifique se você adicionou a chave pública à sua conta GitHub:"
    echo
    echo "🧾 Saída do ssh:"
    echo "$ssh_output"
fi

echo "✅ Chave SSH criada com sucesso!"

