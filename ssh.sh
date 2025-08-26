#!/bin/bash


echo "use : git remote set-url origin git@github.com:user/repo.git"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

function start_ssh_agent_if_needed() {
    if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        echo "🧠 ssh-agent não está rodando. Iniciando ssh-agent..."
        eval "$(ssh-agent -s)"
    else
        echo "🧠 ssh-agent já está rodando com PID $SSH_AGENT_PID."
    fi
}

echo "🔍 Procurando chaves SSH existentes em ~/.ssh..."
chaves_existentes=()
while IFS= read -r chave; do
    chaves_existentes+=("$chave")
done < <(find ~/.ssh -maxdepth 1 -type f ! -name "*.pub" -exec grep -l "PRIVATE KEY" {} + 2>/dev/null)

goto_skip_keygen=false

if [ ${#chaves_existentes[@]} -gt 0 ]; then
    echo "Chaves SSH encontradas:"
    for i in "${!chaves_existentes[@]}"; do
        echo "  [$i] $(basename "${chaves_existentes[$i]}")"
    done
    echo "  [c] Criar uma nova chave SSH"
    read -p "Escolha uma chave existente pelo número ou 'c' para criar nova: " escolha

    if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -lt "${#chaves_existentes[@]}" ]; then
        KEY_NAME="${chaves_existentes[$escolha]}"
        echo "Você escolheu a chave: $KEY_NAME"

        start_ssh_agent_if_needed

        if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$KEY_NAME" | awk '{print $2}')"; then
            echo "➕ Adicionando chave ao ssh-agent..."
            ssh-add "$KEY_NAME"
        else
            echo "🔑 Chave já está adicionada ao ssh-agent."
        fi

        goto_skip_keygen=true
    elif [[ "$escolha" == "c" || "$escolha" == "C" ]]; then
        echo "Você escolheu criar uma nova chave SSH."
        goto_skip_keygen=false
    else
        echo "Opção inválida. Saindo."
        exit 1
    fi
else
    echo "Nenhuma chave SSH encontrada. Vamos criar uma nova."
    goto_skip_keygen=false
fi

if [ "$goto_skip_keygen" != true ]; then
    read -p "Digite o nome da chave SSH (pressione Enter para usar 'id_ed25519'): " chave_nome
    chave_nome=${chave_nome:-id_ed25519}
    KEY_NAME="$HOME/.ssh/$chave_nome"

    read -p "Digite seu e-mail para a chave SSH: " email

    if [ -f "$KEY_NAME" ]; then
        echo "⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever."
        exit 1
    fi

    echo "🔐 Gerando chave SSH..."
    ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

    start_ssh_agent_if_needed

    echo "➕ Adicionando chave ao ssh-agent..."
    ssh-add "$KEY_NAME"

    SSH_CONFIG="$HOME/.ssh/config"
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"

    if ! grep -q "Host github.com" "$SSH_CONFIG"; then
        {
          echo ""
          echo "Host github.com"
          echo "  HostName github.com"
          echo "  User git"
          echo "  IdentityFile $KEY_NAME"
          echo "  IdentitiesOnly yes"
        } >> "$SSH_CONFIG"
        echo "⚙️  ~/.ssh/config atualizado para github.com"
    else
        echo "⚙️  ~/.ssh/config já possui configuração para github.com"
    fi

    echo "📋 Copie manualmente a chave pública abaixo e adicione no GitHub:"
    echo -e "\033[32m"
    cat "$KEY_NAME.pub"
    echo -e "\033[0m"
else
    # Tenta extrair o email da chave escolhida para usar no git config
    email=$(ssh-keygen -lf "$KEY_NAME" | awk '{print $3}')
fi

read -p "Deseja configurar seu nome e e-mail global no Git? (s/n): " configure_git
if [[ "$configure_git" =~ ^[sS]$ ]]; then
    read -p "Digite seu nome completo para o Git: " git_name
    git config --global user.name "$git_name"
    git config --global user.email "$email"
    echo "✅ Git configurado globalmente:"
    echo "   🧑 Nome:  $(git config --global user.name)"
    echo "   📧 E-mail: $(git config --global user.email)"
fi

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
git remote -v
