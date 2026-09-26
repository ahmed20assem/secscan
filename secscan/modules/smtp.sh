#!/bin/bash

TARGET=$1
FINDINGS_FILE=$2

echo "[+] SMTP Service Detected on Port 25" >> "$FINDINGS_FILE"
echo "[-] Fetching SMTP Banner..." >> "$FINDINGS_FILE"

BANNER=$(nc -w 3 "$TARGET" 25 2>&1 | head -n 1)

if [ -n "$BANNER" ]; then
    echo "[!] Evidence: SMTP Banner: $BANNER" >> "$FINDINGS_FILE"
else
    echo "[-] Could not fetch SMTP banner." >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
