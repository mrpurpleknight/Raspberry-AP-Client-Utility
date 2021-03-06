#!/bin/bash

function down() {
    ip link set down br0
    ip link del dev br0
   
    systemctl stop hostapd
    systemctl stop dhcpcd

    clearApFiles

    systemctl restart systemd-networkd

    systemctl disable systemd-networkd
    systemctl stop systemd-networkd.socket 
    systemctl stop systemd-networkd

    systemctl reset-failed
    
    systemctl restart systemd-resolved
    systemctl daemon-reload
    systemctl restart dhcpcd
}

function up() {
    local ssid=$1
    local country_code
    
    systemctl stop dhcpcd

    while IFS= read -r line
    do
        country_code="$line"
    done < "$HOME/.apconfig"

    writeApFiles "$country_code" "$ssid"

    systemctl enable systemd-networkd
    systemctl restart systemd-networkd

    systemctl daemon-reload
    systemctl restart dhcpcd
    systemctl start hostapd
}

function setup() {
    local country_code=$1
    setupAp "$country_code"
}

function clearApFiles() {
    rm -rf /etc/hostapd/hostapd.conf
    rm -rf /etc/systemd/network/bridge-br0.netdev
    rm -rf /etc/systemd/network/br0-member-eth0.network

    rm -rf /etc/dhcpcd.conf
    printf "static domain_name_servers=8.8.4.4 8.8.8.8" > /etc/dhcpcd.conf
    chmod +rwx /etc/dhcpcd.conf

}

function writeApFiles() {
    local country_code=$1;
    local ssid=$2;

    #Add a bridge network device named br0
    printf "[NetDev]\nName=br0\nKind=bridge" >/etc/systemd/network/bridge-br0.netdev
    chmod +rwx /etc/systemd/network/bridge-br0.netdev

    #In order to bridge the Ethernet network with the wireless network, first add the built-in Ethernet interface (eth0) as a bridge member
    printf "[Match]\nName=eth0\n\n[Network]\nBridge=br0" >/etc/systemd/network/br0-member-eth0.network
    chmod +rwx /etc/systemd/network/br0-member-eth0.network

    #dhcpcd, the DHCP client on the Raspberry Pi, automatically requests an IP address for every active interface.
    #So we need to block the eth0 and wlan0 interfaces from being processed, and let dhcpcd configure only br0 via DHCP
    printf "denyinterfaces wlan0 eth0\ninterface br0\nstatic domain_name_servers=8.8.4.4 8.8.8.8" >/etc/dhcpcd.conf
    chmod +rwx /etc/dhcpcd.conf

    printf "country_code=$country_code\ninterface=wlan0\nbridge=br0\nssid=$ssid\nhw_mode=g\nchannel=7\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_passphrase=AccedyBox!\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\n" >/etc/hostapd/hostapd.conf
}

function setupAp() {
    local country_code=$1
    country_code=${country_code^^}
    echo "$country_code" > "$HOME/.apconfig"

    systemctl unmask hostapd

    #Now enable the systemd-networkd service to create and populate the bridge when your Raspberry Pi boots
    systemctl enable systemd-networkd

    #To ensure WiFi radio is not blocked on your Raspberry Pi, execute the following command
    rfkill unblock wlan
    
    writeApFiles "$country_code" "FirstSetup"

    echo "Please reboot the system before typing any other command"
    echo "At first reboot the Access Point will be on under the name of FirstSetup and you need to manually turn off it!"
}

if [ -z "$2" ]; then
    if [ "$1" == "down" ]; then
        down
    else
        echo "Invalid option: $1 is not a recognized command"
    fi
else
    if [ "$1" == "setup" ]; then
        setup "$2"
    elif [ "$1" == "up" ]; then
        up "$2"
    else
        echo "Invalid option: No suitable option"
    fi
fi

