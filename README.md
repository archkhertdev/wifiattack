# WiFi Attack by ARCHKHERT / VCTRAONTOP!

# WiFi Attack Toolkit by Khert

A powerful ethical Wi-Fi attack toolkit for Linux systems that can:
- Broadcast 250+ fake SSIDs (Access Points)
- Deauthenticate all devices from your currently connected Wi-Fi

> Note: This tool is for educational and ethical use only. Only test on networks you own or have permission to audit.

---

## Features

- [x] Auto-detects BSSID and channel of the Wi-Fi you're connected to  
- [x] Fake SSID flood with names like ARCHKHERT-AB12  
- [x] Fully automated deauthentication attack  
- [x] Auto-enables/disables monitor mode  
- [x] Restores NetworkManager on exit (CTRL+C supported)  

---

## Installation

### Install Dependencies

#### For Arch Linux / Manjaro
bash
```sudo pacman -Syu aircrack-ng mdk4 networkmanager```

For Debian / Ubuntu

```sudo apt update```
```sudo apt install aircrack-ng mdk4 network-manager```


---

Clone the Repository

```git clone https://github.com/vctraontop/wifiattack.git```

```cd wifiattack```




---

Connect to Target Wi-Fi

Before launching the script, connect your laptop to the Wi-Fi you want to test:

```nmcli dev wifi connect YOUR_SSID password YOUR_PASSWORD```


---

Run the Tool

```chmod +x wifi_attack_menu_auto.sh```

```sudo ./wifi_attack_menu_auto.sh```


---

Menu Options

==== WiFi Attack Menu ====
1. Broadcast 250 Fake SSIDs
2. Deauth Connected Wi-Fi Automatically
3. Exit


---

Stop the Attack

To stop the tool and restore your network:

CTRL + C

Automatically runs:

sudo airmon-ng stop wlan0mon
sudo systemctl start NetworkManager



---

## NOTE

> This software is provided for educational purposes only. Any misuse is the sole responsibility of the user. Use only on networks you own or have permission to test.

> For Educational Purposes Only

> I am not responsible for any damages this project will do. DO IT AT YOUR OWN RISK
