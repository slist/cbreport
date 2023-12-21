#!/bin/bash

source config.sh

./cbc-alerts-cmdline.py ${CRED_ENTRY} |sort |uniq >alerts_cmdline.txt
./cbc-alerts-ngav.py ${CRED_ENTRY} |sort |uniq >alerts_ngav.txt
./cbc-alerts-stopped.py ${CRED_ENTRY} >alerts_stopped.txt
./cbc-alerts-detected.py ${CRED_ENTRY} >alerts_detected.txt

./cbc-watchlist-alerts.py ${CRED_ENTRY} >alerts_watchlist.txt

TEX_FILE_ALERT_STOPPED="alertstopped.tex"
TEX_FILE_ALERT_DETECTED="alertdetected.tex"
TEX_FILE_ALERT_WATCHLIST="alertwatchlist.tex"

echo -n "\\nicecounter{" > ${TEX_FILE_ALERT_STOPPED}
cat alerts_stopped.txt | tr -d '\n' >> ${TEX_FILE_ALERT_STOPPED}
echo "}{Alerts Stopped}" >> ${TEX_FILE_ALERT_STOPPED}
rm alerts_stopped.txt

echo -n "\\nicecounter{" > ${TEX_FILE_ALERT_DETECTED}
cat alerts_detected.txt | tr -d '\n' >> ${TEX_FILE_ALERT_DETECTED}
echo "}{Alerts Detected}" >> ${TEX_FILE_ALERT_DETECTED}
rm alerts_detected.txt

echo -n "\\nicecounter{" >${TEX_FILE_ALERT_WATCHLIST}
cat alerts_watchlist.txt | tr -d '\n' >>${TEX_FILE_ALERT_WATCHLIST}
echo "}{Watchlist alerts}" >> ${TEX_FILE_ALERT_WATCHLIST}
rm alerts_watchlist.txt

