!/bin/bash

# Cores e estilos
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear
echo "${YELLOW}${BOLD}⚠️  ATENÇÃO:${RESET} Este script permite remover suas chaves SSH e/ou as configurações globais do Git."

echo ""
echo "${CYAN}##############################################${RESET}"
echo
echo "${CYAN}#${RESET} ${BOLD}Escolha uma opção:${RESET}"
echo
echo "${CYAN}##############################################${RESET}"

echo
echo "${GREEN}Dados atuais do git do pc:"
echo "nome : $(git config --global user.name)"
echo "email : $(git config --global user.email)${RESET}"



echo
echo "1) 🗑️  Remover ${BOLD}chaves SSH${RESET} e ${BOLD}configurações do Git${RESET}"
echo "2) 🧹 Remover ${BOLD}apenas configurações do Git${RESET}"
echo "3) ❌ Cancelar"
echo ""
read -p "Digite o número da opção desejada: " option
echo ""

case "$option" in
    1)
        echo "${YELLOW}${BOLD}Você escolheu remover TUDO!${RESET}"
        read -p "Tem certeza que deseja continuar? (s/n): " confirm
        if [[ ! "$confirm" =~ ^[sS]$ ]]; then
            echo "${RED}Abortando.${RESET}"
            exit 1
        fi

        echo ""
        echo "${CYAN}########## FINALIZANDO SSH-AGENT ##########${RESET}"
        sleep 1
        echo "🛑 Encerrando ssh-agent (se estiver ativo)..."
        eval "$(ssh-agent -k)"
        ssh-add -D 2>/dev/null || true

        echo ""
        echo "${CYAN}########## REMOVENDO CHAVES SSH ##########${RESET}"
        sleep 1
        if [ -d "$HOME/.ssh" ]; then
            rm -f ~/.ssh/*
            echo "${GREEN}✅ Chaves SSH removidas.${RESET}"
        else
            echo "${YELLOW}⚠ Nenhuma pasta ~/.ssh encontrada. Nada a remover.${RESET}"
        fi

        echo ""
        echo "${CYAN}########## REMOVENDO CONFIGURAÇÕES DO GIT ##########${RESET}"
        sleep 1
        git config --global --unset user.name 2>/dev/null
        git config --global --unset user.email 2>/dev/null
        echo "${GREEN}✅ Configurações do Git removidas.${RESET}"
        ;;
    
    2)
        echo "${YELLOW}${BOLD}Você escolheu remover apenas as configurações do Git.${RESET}"
        read -p "Tem certeza que deseja continuar? (s/n): " confirm_git
        if [[ ! "$confirm_git" =~ ^[sS]$ ]]; then
            echo "${RED}Abortando.${RESET}"
            exit 1
        fi

        echo ""
        echo "${CYAN}########## REMOVENDO CONFIGURAÇÕES DO GIT ##########${RESET}"
        sleep 1
        git config --global --unset user.name 2>/dev/null
        git config --global --unset user.email 2>/dev/null
        echo "${GREEN}✅ Configurações do Git removidas.${RESET}"
        ;;
    
    3)
        echo "${YELLOW}Operação cancelada pelo usuário.${RESET}"
        exit 0
        ;;
    
    *)
        echo "${RED}❌ Opção inválida. Abortando.${RESET}"
        exit 1
        ;;
esac

echo ""
sleep 1
echo "${GREEN}${BOLD}✅ Operação concluída com sucesso.${RESET}"

echo 
echo "nome : $(git config --global user.name)"
echo "email : $(git config --global user.email)"

echo ""

