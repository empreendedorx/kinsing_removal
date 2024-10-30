#!/bin/bash

# Define o arquivo de log no diretório root
LOGFILE="/root/kinsing_removal.log"

# Função para gravar no log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# ALSO TEST THE SSH STATUS
STATUS_SSH=$(pgrep ssh)
if [[ "${STATUS_SSH}" = "" ]]; then
        /usr/bin/systemctl start ssh
fi

# DELETE PRELOAD LD LIBRARY
echo '' > /etc/ld.so.preload

# BOT SERVICE IS KINSING SERVICE
/usr/bin/systemctl stop bot.service &>/dev/null
/usr/bin/systemctl disable bot.service &>/dev/null

# DELETE BOT SERVICE
echo '' > /lib/systemd/system/bot.service

# KILL THE KINSING FROM NETWORK
KINSING_PROC=$(netstat -tlp | grep kinsing | awk '/kinsing */ {split($NF,a,"/"); print a[1]}')
KDEV_PROC=$(netstat -tlp | grep kdevtmpfsi | awk '/kdevtmpfsi */ {split($NF,a,"/"); print a[1]}')
if [[ $KINSING_PROC =~ ^[0-9]+$ ]]; then
        log "KINSING FOUND IN NETWORK -> ${KINSING_PROC}"
        kill $KINSING_PROC
        log "Killed KINSING process: ${KINSING_PROC}"
fi
if [[ $KDEV_PROC =~ ^[0-9]+$ ]]; then
        log "KDEVTMPFSI FOUND IN NETWORK -> ${KDEV_PROC}"
        kill $KDEV_PROC
        log "Killed KDEV process: ${KDEV_PROC}"
fi

# KILL THE KINSING PROCESS
if [[ $(pgrep kdevtmpfsi) != "" ]];then
        log "MALWARE KDEV FOUND"
        kill $(pgrep kdevtmp)
        log "Killed KDEV process: $(pgrep kdevtmp)"
fi
if [[ $(pgrep kinsing) != "" ]]; then
        log "MALWARE KIN FOUND"
        kill $(pgrep kinsing)
        log "Killed KINSING process: $(pgrep kinsing)"
fi

# REMOVE KINSING FROM TMP & DATA DIRECTORY
if ls /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so &>/dev/null; then
    log "Deleting KINSING-related files"
    rm -f /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so
    log "Deleted KINSING files from /tmp, /var/tmp, and /etc/data"
fi
