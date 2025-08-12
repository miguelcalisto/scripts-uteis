#!/bin/bash

# Script: alterar_dns.sh
# Função: Altera o DNS da conexão ativa e cria um backup restaurável

# Verifica se está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  Por favor, execute como root (use: sudo ./alterar_dns.sh)"
  exit 1
fi

# Verifica a conectividade com a Internet (WSL não tem nmcli)
ping -c 1 google.com &>/dev/null
if [ $? -ne 0 ]; then
  echo "❌ Nenhuma conexão ativa encontrada. Verifique sua conexão com a Internet."
  exit 1
fi

# Caminho do backup
BACKUP_FILE="/etc/resolv.conf.bak"

# Cria backup do resolv.conf se não existir
if [ ! -f "$BACKUP_FILE" ]; then
  echo "🔄 Criando backup do /etc/resolv.conf"
  cp /etc/resolv.conf "$BACKUP_FILE"
  echo "📁 Backup salvo em: $BACKUP_FILE"
else
  echo "📁 Backup já existe: $BACKUP_FILE"
fi

# Menu de DNS
echo "============================="
echo "   Escolha o novo DNS:"
echo "============================="
echo "1 - Cloudflare (1.1.1.1) [Mais rápido e mais seguro]"
echo "2 - Google DNS (8.8.8.8) [Rápido, mas coleta dados]"
echo "3 - AdGuard DNS (94.140.14.14) [Bloqueia anúncios]"
echo "4 - OpenDNS (208.67.222.222) [Seguro e confiável]"
echo "5 - Restaurar DNS original"
echo "6 - Sair"
echo "============================="

read -p "Digite o número da opção desejada: " opcao

# Aplica ou restaura DNS
case $opcao in
  1)
    DNS="1.1.1.1 1.0.0.1"
    NOME="Cloudflare"
    ;;
  2)
    DNS="8.8.8.8 8.8.4.4"
    NOME="Google"
    ;;
  3)
    DNS="94.140.14.14 94.140.15.15"
    NOME="AdGuard"
    ;;
  4)
    DNS="208.67.222.222 208.67.220.220"
    NOME="OpenDNS"
    ;;
  5)
    if [ -f "$BACKUP_FILE" ]; then
      echo "♻️  Restaurando DNS original de /etc/resolv.conf"
      cp "$BACKUP_FILE" /etc/resolv.conf
      echo "✅ DNS restaurado com sucesso!"
    else
      echo "⚠️  Nenhum backup encontrado para restaurar."
    fi
    exit 0
    ;;
  6)
    echo "Saindo..."
    exit 0
    ;;
  *)
    echo "❌ Opção inválida!"
    exit 1
    ;;
esac

# Aplica novo DNS diretamente no /etc/resolv.conf
echo "🔧 Aplicando DNS ($NOME)"
echo -e "nameserver $DNS" > /etc/resolv.conf

echo "✅ DNS alterado com sucesso para: $DNS"

