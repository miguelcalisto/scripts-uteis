#!/bin/bash

sudo -v
if ! command -v figlet &>/dev/null; then
    sudo apt install figlet -y &>/dev/null
fi

GPG="gpg"

pause() {
    echo
    read -rp "Pressione ENTER para continuar..."
}

menu() {
    clear
    echo "=============================="
    figlet GPG
    #    cowsay GPG-SCRIPT
    echo "=============================="
    echo
    pwd
    echo
    echo "1) Criar nova chave"
    echo "2) Listar chaves PUBLICAS"
    echo "3) Listar chaves PRIVADAS"
    echo "4) Exportar chave PUBLICA"
    echo "5) Importar chave PUBLICA"
    echo "6) Criptografar arquivo assimetrica(-e -r)"
    echo "7) Descriptografar arquivo .gpg / ler e verificar .asc"
    echo "8) Apagar chave (publica/privada)"
    echo "9) Assinar arquivo --clearsign "
    echo "10) Verificar assinatura(clearsign .asc)"
    echo "11) Criptografar + Assinar (encrypt + sign)"
    echo "12) Mostrar FINGERPRINT da chave"
    echo "13) Assinar arquivo (detached .sig/.asc)"
    echo "14) Verificar assinatura (detached .sig/.asc)"
    echo "15) Criptografar arquivo simples/simetrica "
    echo "16) Editar chave "

    echo "0) Sair"
    echo
}

criar_chave() {
    echo ">>> Criando nova chave"
    $GPG --full-generate-key
    pause
}

listar_publicas() {
    echo
    echo ">>> Chaves PUBLICAS"
    $GPG --list-keys
    pause
}

listar_privadas() {
    echo
    echo ">>> Chaves PRIVADAS"
    $GPG --list-secret-keys
    pause
}

exportar_publica() {
    read -rp "UID ou email da chave: " uid
    read -rp "Arquivo de saida (ex: chave.asc): " arq
    $GPG --armor --export "$uid" >"$arq"
    echo "Chave exportada em $arq"
    pause
}

importar_publica() {
    read -rp "Arquivo .asc da chave publica: " arq
    $GPG --import "$arq"
    pause
}

criptografar() {
    read -rp "Arquivo para criptografar: " arq
    read -rp "UID/email do destinatario (-r): " uid
    $GPG --encrypt --armor --recipient "$uid" "$arq"
    echo "Arquivo criado: $arq.gpg"
    ls -lah "$arq.gpg"
    pause
}

descriptografar() {
    echo
    read -rp "Arquivo .gpg ou .asc: " arq
    $GPG --decrypt "$arq"
    pause
}

apagar_chave() {
    echo ">>> ATENCAO: apague primeiro a chave PRIVADA"
    read -rp "UID/email da chave: " uid
    echo
    echo "1) Apagar chave PRIVADA"
    echo "2) Apagar chave PUBLICA"
    read -rp "Escolha: " opt

    case $opt in
        1) $GPG --delete-secret-keys "$uid" ;;
        2) $GPG --delete-keys "$uid" ;;
        *) echo "Opcao invalida" ;;
    esac
    pause
}

assinar_arquivo() {
    read -rp "Arquivo para assinar: " arq
    $GPG --clearsign "$arq"
    echo "Arquivo criado: $arq.asc"
    ls -lah "$arq.asc"
    pause
}

verificar_assinatura() {
    echo ">>> Verificar assinatura (.asc)"
    read -rp "Arquivo assinado (.asc): " arq

    $GPG --verify "$arq"
    pause
}

criptografar_assinar() {
    echo ">>> Criptografar + Assinar"
    read -rp "Arquivo para criptografar: " arq
    read -rp "UID/email do destinatario (-r): " uid

    $GPG --encrypt --sign --armor --recipient "$uid" "$arq"

    echo "Arquivo criado: $arq.gpg"
    ls -lah "$arq.gpg"
    pause
}

mostrar_fingerprint() {
    echo
    read -rp "UID ou email da chave: " uid
    echo
    echo ">>> Fingerprint da chave:"
    $GPG --fingerprint "$uid"
    pause
}

assinar_detached() {
    echo ">>> Assinar arquivo (.asc)"
    read -rp "Arquivo para assinar: " arq

    $GPG --armor --detach-sign "$arq"

    echo "Assinatura criada: $arq.asc"
    ls -lah "$arq.asc"
    pause
}

verificar_detached() {
    echo ">>> Verificar assinatura destacada (.asc ou .sig)"
    read -rp "Arquivo ORIGINAL: " arq

    read -rp "Arquivo de assinatura (.sig/.asc): " sig

    $GPG --verify "$sig" "$arq"
    pause
}

criptografia_simetrica() {
    read -rp "Arquivo para proteger com SENHA: " arq

    $GPG --symmetric --armor "$arq"

    if [ $? -eq 0 ]; then

        echo "Arquivo gerado: $arq.gpg"

        read -rp "Rodar gpgconf --kill gpg-agent/tirar as chaves da RAM (s/n): " clean

        if [ "$clean" = "s" ] || [ "$clean" = "S" ]; then
            gpgconf --kill gpg-agent
            echo "Cache limpo! "
        else
            echo "Senhas mantidas na RAM"
        fi

    fi
    pause
}


editar_chave() {
    read -rp "UID/email da chave: " uid
    $GPG --edit-key "$uid"
    pause
}

while true; do
    menu
    read -rp "Escolha: " opc

    case $opc in
        1) criar_chave ;;
        2) listar_publicas ;;
        3) listar_privadas ;;
        4) exportar_publica ;;
        5) importar_publica ;;
        6) criptografar ;;
        7) descriptografar ;;
        8) apagar_chave ;;
        9) assinar_arquivo ;;
        10) verificar_assinatura ;;
        11) criptografar_assinar ;;
        12) mostrar_fingerprint ;;
        13) assinar_detached ;;
        14) verificar_detached ;;
        15) criptografia_simetrica ;;
        16) editar_chave ;;
        0) exit 0 ;;
        *)
            echo "Opcao invalida"
            pause
            ;;
    esac
done
