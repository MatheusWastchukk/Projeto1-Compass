#!/bin/bash

SERVICE="httpd"
export TZ=America/Sao_Paulo
TIMESTAMP=$(date +"%d/%m/%Y %H:%M:%S")
STATUS=$(systemctl is-active $SERVICE)
MESSAGE=""

if [ "$STATUS" = "active" ]; then
    MESSAGE="ONLINE"
    echo "$TIMESTAMP $SERVICE $STATUS $MESSAGE" > /mnt/nfs/matheus_wastchuk/apache_online.log
else
    MESSAGE="OFFLINE"
    echo "$TIMESTAMP $SERVICE $STATUS $MESSAGE" > /mnt/nfs/matheus_wastchuk/apache_offline.log
fi
