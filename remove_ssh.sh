#!/bin/bash

echo "⚠️  ATENÇÃO: Este script permite remover suas chaves SSH e/ou as configurações globais do Git."

echo ""
echo "Escolha uma opção:"
echo "1) Remover chaves SSH e configurações do Git"
echo "2) Remover apenas configurações do Git"
echo "3) Cancelar"
read -p "Digite o número da opção desejada: " option

case "$option" in
    1)
        BACKUP_DIR="$HOME/backup_ssh_$(date +%Y%m%d_%H%M%S)"

        # Confirmação final
        read -p "Tem certeza que deseja remover todas as chaves SSH e as configurações do Git? (s/n): " confirm
        if [[ ! "$confirm" =~ ^[sS]$ ]]; then
            echo "Abortando."
            exit 1
        fi

        # Backup das chaves SSH
        if [ -d "$HOME/.ssh" ]; then
            echo "📦 Criando backup da pasta ~/.ssh em $BACKUP_DIR ..."
            mkdir -p "$BACKUP_DIR"
            cp -r ~/.ssh/* "$BACKUP_DIR/"
            echo "Backup criado com sucesso!"
        else
            echo "Nenhuma pasta ~/.ssh encontrada, nada para fazer backup."
        fi

        # Finaliza ssh-agent
        echo "🛑 Finalizando ssh-agent, se estiver ativo..."
        eval "$(ssh-agent -k)"
        ssh-add -D 2>/dev/null || true

        # Remove chaves
        rm -f ~/.ssh/*

        echo "✅ Chaves SSH removidas!"
        echo "Backup salvo em: $BACKUP_DIR"

        # Remove config Git
        echo "🧹 Removendo configurações globais do Git..."
        git config --global --unset user.name 2>/dev/null
        git config --global --unset user.email 2>/dev/null
        echo "✅ Configurações do Git removidas."
        ;;
    
    2)
        # Confirmação
        read -p "Tem certeza que deseja remover apenas as configurações do Git? (s/n): " confirm_git
        if [[ ! "$confirm_git" =~ ^[sS]$ ]]; then
            echo "Abortando."
            exit 1
        fi

        # Remove config Git
        echo "🧹 Removendo configurações globais do Git..."
        git config --global --unset user.name 2>/dev/null
        git config --global --unset user.email 2>/dev/null
        echo "✅ Configurações do Git removidas."
        ;;
    
    3)
        echo "Operação cancelada."
        exit 0
        ;;
    
    *)
        echo "❌ Opção inválida. Abortando."
        exit 1
        ;;
esac

echo ""
echo "✅ Operação concluída com sucesso."

