#!/bin/bash

TARGET=$1
FINDINGS_FILE=$2

echo "[+] DNS Service Detected on Port 53" >> "$FINDINGS_FILE"

if command -v dig &> /dev/null; then
    echo "[-] Attempting Zone Transfer test..." >> "$FINDINGS_FILE"
    ZONE_OUT=$(dig axfr "@$TARGET" 2>&1)
    
    if echo "$ZONE_OUT" | grep -q "Transfer failed"; then
        echo "[-] Zone transfer refused or failed." >> "$FINDINGS_FILE"
    else
        echo "[!] Evidence: Zone Transfer response:" >> "$FINDINGS_FILE"
        echo "$ZONE_OUT" | head -n 10 >> "$FINDINGS_FILE"
    fi
else
    echo "[-] dig tool not installed, skipping check." >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
