#!/bin/bash
sudo apt update -y > /dev/null 2>&1 &
sudo apt install figlet -y > /dev/null 2>&1 & 
clear

# Diretório ~/.ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'
MAGENTA='\033[1;35m'

echo -e "${MAGENTA}###################################"
echo -e "${MAGENTA}${RESET}${BLUE}                                 ${MAGENTA}"
#echo -e "${MAGENTA}${RESET}${YELLOW}   🛡️ GERADOR DE CHAVE SSH🛡️       ${MAGENTA}"
figlet CHAVES SSH PARA GITHUB  
echo -e "${MAGENTA}${RESET}${BLUE}                                 ${MAGENTA}"
echo -e "${MAGENTA}###################################${RESET}"
echo

#echo -e "🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑🔑"
echo
# -------------------------------------------------------------------------------
# ##### 🧠 Função: Iniciar ssh-agent se necessário #####
# -------------------------------------------------------------------------------
echo
start_ssh_agent_if_needed() {
    if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
        echo -e "${BLUE}##### 🧠 ssh-agent não está rodando. Iniciando... #####${RESET}"
        eval "$(ssh-agent -s)"
    else
        echo -e "${GREEN}##### 🧠 ssh-agent já está rodando com PID $SSH_AGENT_PID. #####${RESET}"
    fi
}

echo -e "${BLUE}##### 🔍 Procurando chaves SSH existentes em ~/.ssh... #####${RESET}"
chaves_existentes=()
while IFS= read -r chave; do
    chaves_existentes+=("$chave")
done < <(find ~/.ssh -maxdepth 1 -type f ! -name "*.pub" -exec grep -l "PRIVATE KEY" {} + 2>/dev/null)

sleep 1

goto_skip_keygen=false

if [ ${#chaves_existentes[@]} -gt 0 ]; then
    echo -e "${GREEN}##### 🔑 Chaves SSH encontradas: #####${RESET}"
    for i in "${!chaves_existentes[@]}"; do
        echo "  [$i] $(basename "${chaves_existentes[$i]}")"
    done
    echo "  [c] Criar uma nova chave SSH"
    echo
    read -p "Escolha uma chave existente pelo número ou 'c' para criar nova: " escolha

    echo
    if [[ "$escolha" =~ ^[0-9]+$ ]] && [ "$escolha" -ge 0 ] && [ "$escolha" -lt "${#chaves_existentes[@]}" ]; then
        KEY_NAME="${chaves_existentes[$escolha]}"
        echo -e "${BLUE}##### 🔐 Você escolheu a chave: $KEY_NAME #####${RESET}"

        start_ssh_agent_if_needed

        sleep 1

        if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$KEY_NAME" | awk '{print $2}')"; then
            echo -e "${BLUE}##### ➕ Adicionando chave ao ssh-agent... #####${RESET}"
            ssh-add "$KEY_NAME"

            # === ADIÇÃO: Exibir chave pública correspondente para cópia ===
            if [ -f "${KEY_NAME}.pub" ]; then
                echo -e "\n##### 📋 Copie a chave pública abaixo e adicione ao GitHub: #####\n"
                echo -e "${GREEN}"
                cat "${KEY_NAME}.pub"
                echo -e "${RESET}"
            else
                echo -e "${RED}##### ❌ Arquivo ${KEY_NAME}.pub não encontrado. #####${RESET}"
            fi
            # ===========================================================
        else
            echo -e "${GREEN}##### 🔑 Chave já está adicionada ao ssh-agent. #####${RESET}"

            # Mesmo que já esteja adicionada, mostrar chave pública caso exista (útil para cópia)
            if [ -f "${KEY_NAME}.pub" ]; then
                echo -e "\n##### 📋 Chave pública (já adicionada) — copie abaixo: #####\n"
                echo -e "${GREEN}"
                cat "${KEY_NAME}.pub"
                echo -e "${RESET}"
            fi
        fi

        goto_skip_keygen=true
    elif [[ "$escolha" == "c" || "$escolha" == "C" ]]; then
        echo -e "${BLUE}##### 🛠️ Criando nova chave SSH... #####${RESET}"
        goto_skip_keygen=false
    else
        echo -e "${RED}##### ❌ Opção inválida. Saindo. #####${RESET}"
        exit 1
    fi
else
    echo -e "${YELLOW}##### ⚠️ Nenhuma chave SSH encontrada. Vamos criar uma nova. #####${RESET}"
    goto_skip_keygen=false
fi

sleep 1

# -------------------------------------------------------------------------------
# ##### 🛠️ Geração da nova chave SSH #####
# -------------------------------------------------------------------------------
if [ "$goto_skip_keygen" != true ]; then
    read -p "Digite o nome da chave SSH (Enter para 'id_ed25519'): " chave_nome
    chave_nome=${chave_nome:-id_ed25519}
    KEY_NAME="$HOME/.ssh/$chave_nome"

    read -p "Digite seu e-mail para a chave SSH: " email
    echo
    if [ -f "$KEY_NAME" ]; then
        echo -e "${RED}##### ⚠️  A chave $KEY_NAME já existe. Abortando para não sobrescrever. #####${RESET}"
        exit 1
    fi

    echo -e "${BLUE}##### 🔐 Gerando chave SSH... #####${RESET}"
    ssh-keygen -t ed25519 -C "$email" -f "$KEY_NAME" -N ""

    sleep 1

    start_ssh_agent_if_needed

    sleep 1

    echo -e "${BLUE}##### ➕ Adicionando chave ao ssh-agent... #####${RESET}"
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
        echo -e "${GREEN}##### ⚙️  ~/.ssh/config atualizado com sucesso. #####${RESET}"
    else
        echo -e "${YELLOW}##### ⚙️  ~/.ssh/config já possui entrada para github.com #####${RESET}"
    fi

    echo -e "\n##### 📋 Copie a chave pública abaixo e adicione ao GitHub: #####\n"
    echo -e "${GREEN}"
    cat "$KEY_NAME.pub"
    echo -e "${RESET}"
else
    email=$(ssh-keygen -lf "$KEY_NAME" | awk '{print $3}')
fi

sleep 1

# -------------------------------------------------------------------------------
# ##### 🛠️ Configuração global do Git #####
# -------------------------------------------------------------------------------
echo

echo "Name: $(git config user.name)"
echo "Email: $(git config user.email)"

echo
read -p "Deseja configurar seu nome e e-mail global no Git? (s/n): " configure_git

if [[ "$configure_git" =~ ^[sS]$ ]]; then
    read -p "Digite seu nome completo para o Git: " git_name
    git config --global user.name "$git_name"
    git config --global user.email "$email"
    echo
    echo -e "${GREEN}##### ✅ Git configurado: #####${RESET}"
    echo "   🧑 Nome:  $(git config --global user.name)"
    echo "   📧 E-mail: $(git config --global user.email)"
fi

sleep 1

# -------------------------------------------------------------------------------
# ##### 🌐 Testando conexão SSH com o GitHub #####
# -------------------------------------------------------------------------------
echo -e "\n##### 🌐 Testando conexão com o GitHub... #####"
ssh_output=$(ssh -T git@github.com 2>&1)

if echo "$ssh_output" | grep -q "successfully authenticated"; then
    echo -e "${GREEN}##### ✅ Conexão estabelecida com sucesso! 🎉 #####${RESET}"
    echo "$ssh_output"
else
    echo -e "${RED}##### ❌ Falha ao conectar ao GitHub via SSH. #####${RESET}"
    echo -e "${YELLOW}##### 🔍 Verifique se adicionou a chave pública à sua conta GitHub. #####${RESET}"
    echo -e "\n##### 🧾 Saída do ssh: #####"
    echo "$ssh_output"
fi

sleep 1

# -------------------------------------------------------------------------------
# ##### ✅ Finalização #####
# -------------------------------------------------------------------------------
echo
echo -e "${GREEN}##### ✅ Processo finalizado com sucesso! #####${RESET}"
echo
echo -e "${YELLOW}Use: git remote set-url origin git@github.com:usuario/repositorio.git${RESET}"
echo

git remote -v

echo

# Mostra a chave pública finalmente (se existir)
if [ -f "${KEY_NAME}.pub" ]; then
    echo -e "${GREEN}$(cat "$KEY_NAME.pub")${RESET}"
fi
echo

