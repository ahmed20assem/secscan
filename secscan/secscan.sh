#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <TARGET_IP>"
    exit 1
fi

TARGET=$1
REPORT_DIR="reports/${TARGET}"
SCAN_FILE="${REPORT_DIR}/scan.txt"
FINDINGS_FILE="${REPORT_DIR}/findings.txt"
SUMMARY_FILE="${REPORT_DIR}/summary.txt"

mkdir -p "$REPORT_DIR"

for cmd in nmap curl nc; do
    if ! command -v $cmd &> /dev/null; then
        echo "[-] Error: Required tool '$cmd' is not installed."
        exit 1
    fi
done

echo "=== Security Assessment Summary ===" > "$SUMMARY_FILE"
echo "Target: $TARGET" >> "$SUMMARY_FILE"
echo "Date: $(date)" >> "$SUMMARY_FILE"
echo "----------------------------------" >> "$SUMMARY_FILE"

echo "[*] Checking if target $TARGET is reachable..."
ping -c 2 "$TARGET" &> /dev/null
if [ $? -ne 0 ]; then
    echo "[-] Error: Target $TARGET is unreachable."
    echo "Status: Host Unreachable" >> "$SUMMARY_FILE"
    exit 1
fi

echo "[+] Target is UP."
echo "Status: Online" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "[*] Running Nmap port scan..."
nmap -sV -T4 "$TARGET" -oG "${REPORT_DIR}/nmap_grep.txt" > "$SCAN_FILE"

echo "=== Open Ports & Services ===" >> "$SUMMARY_FILE"
grep "Ports:" "${REPORT_DIR}/nmap_grep.txt" | sed 's/.*Ports: //' | tr ',' '\n' | grep "open" | awk -F'/' '{print "Port: "$1" | Service: "$5}' >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "=== Detailed Evidence & Findings ===" > "$FINDINGS_FILE"

echo "[*] Executing service-specific modules..."
OPEN_PORTS=$(grep "Ports:" "${REPORT_DIR}/nmap_grep.txt" | grep -o "[0-9]*/open" | cut -d'/' -f1)

for PORT in $OPEN_PORTS; do
    case $PORT in
        21)
            [ -f "./modules/ftp.sh" ] && bash ./modules/ftp.sh "$TARGET" "$FINDINGS_FILE"
            ;;
        22)
            [ -f "./modules/ssh.sh" ] && bash ./modules/ssh.sh "$TARGET" "$FINDINGS_FILE"
            ;;
        25)
            [ -f "./modules/smtp.sh" ] && bash ./modules/smtp.sh "$TARGET" "$FINDINGS_FILE"
            ;;
        53)
            [ -f "./modules/dns.sh" ] && bash ./modules/dns.sh "$TARGET" "$FINDINGS_FILE"
            ;;
        80|443|8080)
            [ -f "./modules/http.sh" ] && bash ./modules/http.sh "$TARGET" "$PORT" "$FINDINGS_FILE"
            ;;
        139|445)
            [ -f "./modules/smb.sh" ] && bash ./modules/smb.sh "$TARGET" "$FINDINGS_FILE"
            ;;
    esac
done

echo "[+] Assessment finished. Reports created inside $REPORT_DIR"
