#!/bin/bash

TARGET=$1
FINDINGS_FILE=$2

echo "[+] SSH Service Detected on Port 22" >> "$FINDINGS_FILE"
echo "[-] Fetching SSH Banner..." >> "$FINDINGS_FILE"

BANNER=$(nc -w 3 "$TARGET" 22 2>&1 | head -n 1)

if [ -n "$BANNER" ]; then
    echo "[!] Evidence: SSH Banner Info: $BANNER" >> "$FINDINGS_FILE"
else
    echo "[-] Could not retrieve SSH Banner." >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
