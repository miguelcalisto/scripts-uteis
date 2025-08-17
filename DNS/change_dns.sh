#!/bin/bash

# Script: alterar_dns.sh
# Função: Altera o DNS da conexão ativa e cria um backup restaurável

# Verifica se está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  Por favor, execute como root (use: sudo ./alterar_dns.sh)"
  exit 1
fi

# Obtém a conexão de rede ativa
CONEXAO=$(nmcli -t -f NAME connection show --active | head -n 1)

if [ -z "$CONEXAO" ]; then
  echo "❌ Nenhuma conexão ativa encontrada."
  exit 1
fi

# Caminho do backup
BACKUP_DIR="/etc/nm-dns-backup"
BACKUP_FILE="$BACKUP_DIR/${CONEXAO}.bak"

# Cria diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

# Faz backup das configurações DNS atuais (se ainda não existir)
if [ ! -f "$BACKUP_FILE" ]; then
  echo "🔄 Criando backup da conexão: $CONEXAO"
  {
    echo "dns=$(nmcli -g ipv4.dns connection show "$CONEXAO")"
    echo "ignore_auto_dns=$(nmcli -g ipv4.ignore-auto-dns connection show "$CONEXAO")"
  } > "$BACKUP_FILE"
  echo "📁 Backup salvo em: $BACKUP_FILE"
else
  echo "📁 Backup já existe: $BACKUP_FILE"
fi

# Menu de DNS
echo "============================="
echo "   Escolha o novo DNS:"
echo "============================="
echo "1  - Cloudflare (1.1.1.1)           [rápido, Cloudflare]"
echo "2  - Google DNS (8.8.8.8)           [Rápido, mas coleta dados]"
echo "3  - AdGuard DNS (94.140.14.14)     [Bloqueia anúncios]"
echo "4  - OpenDNS (208.67.222.222)       [Cisco]"
echo "5  - Quad9 (9.9.9.9)                [Privacidade]"
echo "6  - Family Filter (185.228.168.168)[]"
echo "7  - Comodo Secure DNS (8.26.56.26) [Proteção básica]"
echo "8  - Yandex DNS (77.88.8.8)         [segurança extra]"
echo "9  - Neustar DNS (156.154.70.1)     [Estável]"
echo "10 - DNS.Watch (84.200.69.80)       [Sem registro de dados, mas lento]"
echo "11 - UncensoredDNS (91.239.100.100) [Open Source]"
echo "12 - Restaurar DNS original"
echo "13 - Sair"
echo "============================="

read -p "Digite o número da opção desejada: " opcao

# Aplica ou restaura DNS
case $opcao in
  1)
    DNS="1.1.1.1 1.0.0.1"
    DNSV6="2606:4700:4700::1111 2606:4700:4700::1001"
    NOME="Cloudflare"
    ;;
  2)
    DNS="8.8.8.8 8.8.4.4"
    DNSV6="2001:4860:4860::8888 2001:4860:4860::8844"
    NOME="Google"
    ;;
  3)
    DNS="94.140.14.14 94.140.15.15"
    DNSV6="2a10:50c0::ad1:ff 2a10:50c0::ad2:ff"
    NOME="AdGuard"
    ;;
  4)
    DNS="208.67.222.222 208.67.220.220"
    DNSV6=""
    NOME="OpenDNS"
    ;;
  5)
    DNS="9.9.9.9 149.112.112.112"
    DNSV6="2620:fe::fe 2620:fe::9"
    NOME="Quad9"
    ;;
  6)
    DNS="185.228.168.168 185.228.169.168"
    DNSV6="2a0d:2a00:1:: 2a0d:2a00:2::"
    NOME="CleanBrowsing (Family Filter)"
    ;;
  7)
    DNS="8.26.56.26 8.20.247.20"
    DNSV6=""
    NOME="Comodo Secure DNS"
    ;;
  8)
    DNS="77.88.8.8 77.88.8.1"
    DNSV6=""
    NOME="Yandex DNS"
    ;;
  9)
    DNS="156.154.70.1 156.154.71.1"
    DNSV6=""
    NOME="Neustar DNS"
    ;;
  10)
    DNS="84.200.69.80 84.200.70.40"
    DNSV6=""
    NOME="DNS.Watch"
    ;;
  11)
    DNS="91.239.100.100 89.233.43.71"
    DNSV6="2001:67c:28a4:: 2a01:3a0:53:53::"
    NOME="UncensoredDNS (Open Source)"
    ;;
  12)
    if [ -f "$BACKUP_FILE" ]; then
      echo "♻️  Restaurando DNS original da conexão: $CONEXAO"
      source "$BACKUP_FILE"
      nmcli connection modify "$CONEXAO" ipv4.dns "$dns"
      nmcli connection modify "$CONEXAO" ipv4.ignore-auto-dns "$ignore_auto_dns"
      nmcli connection modify "$CONEXAO" ipv6.dns ""
      nmcli connection modify "$CONEXAO" ipv6.ignore-auto-dns no
      nmcli connection down "$CONEXAO" && nmcli connection up "$CONEXAO"
      echo "✅ DNS restaurado com sucesso!"
      
      echo "🔍 Testando conectividade com a internet..."
      ping -c 2 -W 2 1.1.1.1 >/dev/null 2>&1 && echo "✅ IPv4 OK!" || echo "⚠️  IPv4 com problemas."
      ping6 -c 2 -W 2 2606:4700:4700::1111 >/dev/null 2>&1 && echo "✅ IPv6 OK!" || echo "ℹ️  IPv6 não disponível."
      exit 0
    else
      echo "⚠️  Nenhum backup encontrado para restaurar."
      exit 1
    fi
    ;;
  13)
    echo "Saindo..."
    exit 0
    ;;
  *)
    echo "❌ Opção inválida!"
    exit 1
    ;;
esac

# Aplica novo DNS
echo "🔧 Aplicando DNS ($NOME) na conexão: $CONEXAO"
nmcli connection modify "$CONEXAO" ipv4.dns "$DNS"
nmcli connection modify "$CONEXAO" ipv4.ignore-auto-dns yes

if [ -n "$DNSV6" ]; then
  echo "🌐 Aplicando DNS IPv6: $DNSV6"
  nmcli connection modify "$CONEXAO" ipv6.dns "$DNSV6"
  nmcli connection modify "$CONEXAO" ipv6.ignore-auto-dns yes
else
  nmcli connection modify "$CONEXAO" ipv6.dns ""
  nmcli connection modify "$CONEXAO" ipv6.ignore-auto-dns no
fi

# Reinicia a conexão
nmcli connection down "$CONEXAO" && nmcli connection up "$CONEXAO"

# Teste de conectividade
echo "🔍 Testando conectividade com a internet..."
if ping -c 2 -W 2 1.1.1.1 >/dev/null 2>&1 || ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1; then
  echo "✅ Conectividade IPv4 OK!"
else
  echo "⚠️  Sem resposta de IPv4. Verifique o DNS ou a conexão."
fi

if ping6 -c 2 -W 2 2606:4700:4700::1111 >/dev/null 2>&1 || ping6 -c 2 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
  echo "✅ Conectividade IPv6 OK!"
else
  echo "ℹ️  Sem resposta via IPv6."
fi

echo "✅ DNS alterado com sucesso para: $DNS"

