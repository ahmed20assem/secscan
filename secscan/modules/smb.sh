#!/bin/bash

TARGET=$1
FINDINGS_FILE=$2

echo "[+] SMB Service Detected" >> "$FINDINGS_FILE"

if command -v smbclient &> /dev/null; then
    echo "[-] Checking Null Session / Public Shares..." >> "$FINDINGS_FILE"
    SHARES=$(smbclient -L "//$TARGET" -N 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "[!] Evidence: SMB Anonymous/Null list allowed:" >> "$FINDINGS_FILE"
        echo "$SHARES" | head -n 15 >> "$FINDINGS_FILE"
    else
        echo "[-] SMB Null session failed." >> "$FINDINGS_FILE"
    fi
else
    echo "[-] smbclient tool not installed, skipping detailed check." >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
