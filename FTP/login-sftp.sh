#!/usr/bin/env bash

read -p "IP: " IP

read -p "USUARIO: " USER

if ! ping -c 1 $IP &>/dev/null; then
    echo sem conexao com $IP
    exit 1
fi
sftp $USER@$IP

echo ""
SAIDA=$?
if [[ $SAIDA -ne 0 ]]; then

    echo ERRO $SAIDA
else
    echo FIM
fi
