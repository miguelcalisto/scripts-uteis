#!/bin/bash
# ============================================================
# Script: fix_hotspot.sh
# Autor: Miguel (adaptado por ChatGPT)
# Função: Detecta e corrige quando o Docker quebra o hotspot.
# ============================================================

# Interfaces — ajuste se seus nomes forem diferentes
NET_INTERFACE="enp1s0"      # Interface que tem internet (Ethernet)
HOTSPOT_INTERFACE="wlp0s20f3"  # Interface do ponto de acesso Wi-Fi

echo "[INFO] Verificando interfaces..."

# Verifica se o hotspot está ativo
if ! ip link show "$HOTSPOT_INTERFACE" | grep -q "UP"; then
  echo "[ERRO] Hotspot ($HOTSPOT_INTERFACE) não está ativo. Abortando."
  exit 1
fi

# Verifica se a interface principal tem internet
ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "[ERRO] Sem internet na interface principal ($NET_INTERFACE)."
  exit 1
fi

# Verifica se já existe uma regra de MASQUERADE
if sudo iptables -t nat -C POSTROUTING -o "$NET_INTERFACE" -j MASQUERADE 2>/dev/null; then
  echo "[OK] Regra NAT já existe. Nenhuma ação necessária."
else
  echo "[INFO] Corrigindo regras de roteamento..."
  sudo iptables -t nat -A POSTROUTING -o "$NET_INTERFACE" -j MASQUERADE
  sudo iptables -A FORWARD -i "$HOTSPOT_INTERFACE" -o "$NET_INTERFACE" -j ACCEPT
  sudo iptables -A FORWARD -i "$NET_INTERFACE" -o "$HOTSPOT_INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT
  echo "[OK] Regras de NAT aplicadas com sucesso!"
fi

echo "[FINALIZADO] Hotspot deve estar com internet agora."
