#!/bin/bash

TARGET=$1
PORT=$2
FINDINGS_FILE=$3

echo "[+] HTTP Service Detected on Port $PORT" >> "$FINDINGS_FILE"

echo "[-] Fetching HTTP Headers:" >> "$FINDINGS_FILE"
curl -s -I "http://${TARGET}:${PORT}" | head -n 10 >> "$FINDINGS_FILE"

ROBOTS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${TARGET}:${PORT}/robots.txt")
if [ "$ROBOTS_STATUS" -eq 200 ]; then
    echo "[!] Evidence: Found robots.txt file!" >> "$FINDINGS_FILE"
    echo "--- robots.txt content ---" >> "$FINDINGS_FILE"
    curl -s "http://${TARGET}:${PORT}/robots.txt" | head -n 15 >> "$FINDINGS_FILE"
    echo "--------------------------" >> "$FINDINGS_FILE"
else
    echo "[-] robots.txt not found (Status Code: $ROBOTS_STATUS)" >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
