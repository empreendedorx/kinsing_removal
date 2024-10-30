#!/bin/bash

# Define o arquivo de log no diretório root
LOGFILE="/root/kinsing_removal.log"

# Função para gravar no log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# TESTA O STATUS DO SSH
STATUS_SSH=$(pgrep ssh)
if [[ "${STATUS_SSH}" = "" ]]; then
        /usr/bin/systemctl start ssh
fi

# EXCLUI A BIBLIOTECA LD PRELOAD
echo '' > /etc/ld.so.preload

# SERVIÇO BOT É O SERVIÇO KINSING
/usr/bin/systemctl stop bot.service &>/dev/null
/usr/bin/systemctl disable bot.service &>/dev/null

# EXCLUI O SERVIÇO BOT
echo '' > /lib/systemd/system/bot.service

# MATA O PROCESSO KINSING NA REDE
KINSING_PROC=$(netstat -tlp | grep kinsing | awk '/kinsing */ {split($NF,a,"/"); print a[1]}')
KDEV_PROC=$(netstat -tlp | grep kdevtmpfsi | awk '/kdevtmpfsi */ {split($NF,a,"/"); print a[1]}')
if [[ $KINSING_PROC =~ ^[0-9]+$ ]]; then
        log "KINSING ENCONTRADO NA REDE -> ${KINSING_PROC}"
        kill $KINSING_PROC
        log "Processo KINSING finalizado: ${KINSING_PROC}"
fi
if [[ $KDEV_PROC =~ ^[0-9]+$ ]]; then
        log "KDEVTMPFSI ENCONTRADO NA REDE -> ${KDEV_PROC}"
        kill $KDEV_PROC
        log "Processo KDEV finalizado: ${KDEV_PROC}"
fi

# MATA O PROCESSO KINSING
if [[ $(pgrep kdevtmpfsi) != "" ]];then
        log "MALWARE KDEV ENCONTRADO"
        kill $(pgrep kdevtmp)
        log "Processo KDEV finalizado: $(pgrep kdevtmp)"
fi
if [[ $(pgrep kinsing) != "" ]]; then
        log "MALWARE KIN ENCONTRADO"
        kill $(pgrep kinsing)
        log "Processo KINSING finalizado: $(pgrep kinsing)"
fi

# REMOVE KINSING DOS DIRETÓRIOS TMP E DATA
if ls /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so &>/dev/null; then
    log "Excluindo arquivos relacionados ao KINSING"
    rm -f /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so
    log "Arquivos KINSING excluídos de /tmp, /var/tmp e /etc/data"
fi
