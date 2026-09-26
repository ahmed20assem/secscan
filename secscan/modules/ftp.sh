#!/bin/bash

TARGET=$1
FINDINGS_FILE=$2

echo "[+] FTP Service Detected on Port 21" >> "$FINDINGS_FILE"
echo "[-] Checking Anonymous FTP Access..." >> "$FINDINGS_FILE"

FTP_OUT=$(curl -s --max-time 5 "ftp://${TARGET}/" --user anonymous:anonymous 2>&1)

if [ $? -eq 0 ]; then
    echo "[!] Evidence: Anonymous FTP Login Allowed!" >> "$FINDINGS_FILE"
    echo "--- Directory Listing ---" >> "$FINDINGS_FILE"
    echo "$FTP_OUT" | head -n 10 >> "$FINDINGS_FILE"
    echo "-------------------------" >> "$FINDINGS_FILE"
else
    echo "[-] Anonymous FTP Login Failed." >> "$FINDINGS_FILE"
fi

echo "" >> "$FINDINGS_FILE"
