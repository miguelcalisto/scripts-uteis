#!/bin/bash

echo "use : git remote set-url origin git@github.com:user/repo.git"

# Cria a pasta ~/.ssh com as permissões corretas
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Solicita o nome do arquivo da chave SSH
read -p "Digite o nome da chave SSH (pressione Enter para usar 'id_ed25519'): " chave_nome
chave_nome=${chave_nome:-id_ed25519}
KEY_NAME="$HOME/.ssh/$chave_nome"

# Solicita o e-mail para o comentário da chave
read -p "Digite seu e-mail para a chave SSH: " email

# Verifica se a chave já existe
if [ -f "$KEY_NAME" ]; then
    echo "⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever."
    exit 1
fi

# Gera a chave SSH
echo "🔐 Gerando chave SSH..."
ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

# Inicia o ssh-agent (se necessário) e adiciona a chave
echo "🧠 Configurando ssh-agent..."
eval "$(ssh-agent -s)"

echo "➕ Adicionando chave ao ssh-agent..."
ssh-add "$KEY_NAME"

# Atualiza o arquivo ~/.ssh/config para forçar o uso da chave com GitHub
SSH_CONFIG="$HOME/.ssh/config"
echo "⚙️  Atualizando ~/.ssh/config para usar a chave com GitHub..."
{
  echo ""
  echo "Host github.com"
  echo "  HostName github.com"
  echo "  User git"
  echo "  IdentityFile $KEY_NAME"
  echo "  IdentitiesOnly yes"
} >> "$SSH_CONFIG"

chmod 600 "$SSH_CONFIG"

# Exibe a chave pública para cópia manual com cor verde
echo "📋 Copie manualmente a chave pública abaixo e adicione no GitHub:"
echo -e "\033[32m"
cat "$KEY_NAME.pub"
echo -e "\033[0m"

# Configuração global do Git (opcional)
read -p "Deseja configurar seu nome e e-mail global no Git? (s/n): " configure_git
if [[ "$configure_git" =~ ^[sS]$ ]]; then
    read -p "Digite seu nome completo para o Git: " git_name
    git config --global user.name "$git_name"
    git config --global user.email "$email"
    echo "✅ Git configurado globalmente:"
    echo "   🧑 Nome:  $(git config --global user.name)"
    echo "   📧 E-mail: $(git config --global user.email)"
fi

# Testa a conexão com o GitHub
echo
echo "🌐 Testando conexão com o GitHub..."
ssh_output=$(ssh -T git@github.com 2>&1)

if echo "$ssh_output" | grep -q "successfully authenticated"; then
    echo "✅ Conexão estabelecida com sucesso! Sua chave SSH está funcionando. 🎉"
else
    echo "⚠️  Não foi possível se conectar ao GitHub via SSH."
    echo "🔍 Verifique se você adicionou a chave pública à sua conta GitHub:"
    echo
    echo "🧾 Saída do ssh:"
    echo "$ssh_output"
fi

echo
echo "✅ Processo finalizado!"
echo "use : git remote set-url origin git@github.com:user/repo.git"

