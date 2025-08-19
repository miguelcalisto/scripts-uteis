#!/bin/bash

echo "use :git remote set-url origin git@github.com:user/rep.git"

# Cria a pasta ~/.ssh com as permissões corretas, se não existir
mkdir -p ~/.ssh

# Solicita o nome do arquivo da chave SSH
read -p "Digite o nome da chave SSH (pressione Enter para usar 'id_ed25519'): " chave_nome
chave_nome=${chave_nome:-id_ed25519}
KEY_NAME="$HOME/.ssh/$chave_nome"

# Solicita o e-mail que será usado no comentário da chave
read -p "Digite seu e-mail para a chave SSH: " email

# Verifica se a chave já existe
if [ -f "$KEY_NAME" ]; then
    echo "⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever."
    exit 1
fi

# Gera a chave SSH
echo "🔐 Gerando chave SSH..."
ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

# Inicia o ssh-agent, se necessário
echo "🧠 Verificando ssh-agent..."
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "🚀 ssh-agent não está rodando. Iniciando..."
    eval "$(ssh-agent -s)"
else
    echo "✅ ssh-agent já está em execução."
fi

# Adiciona a chave ao ssh-agent, se ainda não estiver adicionada
if ssh-add -l 2>/dev/null | grep -q "$KEY_NAME"; then
    echo "🔐 A chave já está adicionada ao ssh-agent."
else
    echo "➕ Adicionando chave ao ssh-agent..."
    ssh-add "$KEY_NAME"
fi

# Exibe a chave pública para cópia manual
echo
echo "📋 Copie manualmente a chave pública abaixo e adicione no GitHub:"
echo
cat "$KEY_NAME.pub"

echo

# Configuração global do Git
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
echo
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

echo
cat "$KEY_NAME.pub"
echo

echo
echo "✅ Processo finalizado!"

