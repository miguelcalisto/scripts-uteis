#!/bin/bash

BACKUP_DIR="$HOME/backup_ssh_$(date +%Y%m%d_%H%M%S)"

echo "⚠️  ATENÇÃO: Este script vai remover todas as suas chaves SSH e configurações atuais."
read -p "Deseja continuar? (s/n): " confirm

if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Abortando."
    exit 1
fi

# Cria backup das chaves SSH atuais
if [ -d "$HOME/.ssh" ]; then
    echo "📦 Criando backup da pasta ~/.ssh em $BACKUP_DIR ..."
    mkdir -p "$BACKUP_DIR"
    cp -r ~/.ssh/* "$BACKUP_DIR/"
    echo "Backup criado com sucesso!"
else
    echo "Nenhuma pasta ~/.ssh encontrada, nada para fazer backup."
fi

# Finaliza ssh-agent, se estiver rodando
echo "🛑 Finalizando ssh-agent, se estiver ativo..."
eval "$(ssh-agent -k)"

# Limpa identidades no ssh-add (por segurança)
ssh-add -D 2>/dev/null || true

echo "✅ Reset das chaves SSH concluído!"

echo "Você pode agora rodar seu script para gerar novas chaves SSH."

echo "Backup das chaves antigas está salvo em: $BACKUP_DIR"

