#!/bin/bash

# Define the log file in the root directory
LOGFILE="/root/kinsing_removal.log"

# Function to write to the log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# TESTS THE STATUS OF SSH
STATUS_SSH=$(pgrep ssh)
if [[ "${STATUS_SSH}" = "" ]]; then
        /usr/bin/systemctl start ssh
fi

# CLEARS THE LD PRELOAD LIBRARY
echo '' > /etc/ld.so.preload

# BOT SERVICE IS THE KINSING SERVICE
/usr/bin/systemctl stop bot.service &>/dev/null
/usr/bin/systemctl disable bot.service &>/dev/null

# DELETE THE BOT SERVICE
echo '' > /lib/systemd/system/bot.service

# KILL THE KINSING PROCESS IN THE NETWORK
KINSING_PROC=$(netstat -tlp | grep kinsing | awk '/kinsing */ {split($NF,a,"/"); print a[1]}')
KDEV_PROC=$(netstat -tlp | grep kdevtmpfsi | awk '/kdevtmpfsi */ {split($NF,a,"/"); print a[1]}')
if [[ $KINSING_PROC =~ ^[0-9]+$ ]]; then
        log "KINSING FOUND IN THE NETWORK -> ${KINSING_PROC}"
        kill $KINSING_PROC
        log "Killed KINSING process: ${KINSING_PROC}"
fi
if [[ $KDEV_PROC =~ ^[0-9]+$ ]]; then
        log "KDEVTMPFSI FOUND IN THE NETWORK -> ${KDEV_PROC}"
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
        log "MALWARE KINSING FOUND"
        kill $(pgrep kinsing)
        log "Killed KINSING process: $(pgrep kinsing)"
fi

# REMOVE KINSING FROM TMP & DATA DIRECTORIES
if ls /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so &>/dev/null; then
    log "Deleting KINSING-related files"
    rm -f /tmp/kdevtmpfsi* /tmp/kinsing* /var/tmp/kinsing* /var/tmp/kdevtmpfsi* /etc/data/kinsing /etc/data/libsystem.so
    log "Deleted KINSING files from /tmp, /var/tmp, and /etc/data"
fi
