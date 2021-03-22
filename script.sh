#!/bin/bash

function client() {
    if [ "$1" == "up" ]; then
        ifconfig wlan0 up
    elif [ "$1" == "down" ]; then
        ifconfig wlan0 down
    else
        echo "Invalid option: No suitable option"
    fi
}

function ap() {
    if [ "$1" == "up" ]; then
        printf "denyinterfaces wlan0 eth0\ninterface br0" >>/etc/dhcpcd.conf

        systemctl daemon-reload
        systemctl restart dhcpcd
        systemctl start hostapd
    elif [ "$1" == "down" ]; then
        systemctl stop hostapd

        rm -rf /etc/dhcpcd.conf
        touch /etc/dhcpcd.conf

        systemctl daemon-reload
        systemctl restart dhcpcd
    elif [ [ "$1" = "setup"* ] ]; then
        local country_code = $(echo $1 | cut -d '_' -f 2)
        setupAp "$country_code"
    else
        echo "Invalid option: No suitable option"
    fi
}

function setupAp() {
    systemctl unmask hostapd

    #Add a bridge network device named br0
    printf "[NetDev]\nName=br0\nKind=bridge" >>/etc/systemd/network/bridge-br0.netdev

    #In order to bridge the Ethernet network with the wireless network, first add the built-in Ethernet interface (eth0) as a bridge member
    printf "[Match]\nName=eth0\n\n[Network]\nBridge=br0" >>/etc/systemd/network/br0-member-eth0.network

    #Now enable the systemd-networkd service to create and populate the bridge when your Raspberry Pi boots
    sudo systemctl enable systemd-networkd

    #dhcpcd, the DHCP client on the Raspberry Pi, automatically requests an IP address for every active interface.
    #So we need to block the eth0 and wlan0 interfaces from being processed, and let dhcpcd configure only br0 via DHCP
    printf "denyinterfaces wlan0 eth0\ninterface br0" >>/etc/dhcpcd.conf

    #To ensure WiFi radio is not blocked on your Raspberry Pi, execute the following command
    rfkill unblock wlan
    code=$1
    code=${code^^}
    printf "country_code=$code\ninterface=wlan0\nbridge=br0\nssid=AccedyBox\nhw_mode=g\nchannel=7\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_passphrase=AccedyBox!\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\n" >>/etc/hostapd/hostapd.conf

    echo "Please reboot the system before typing any other command"
}

if [ "$1" == "--ap" ]; then
    ap "$2"
elif [ "$1" == "--client" ]; then
    client "$2"
else
    echo "Invalid option: $0 requires an argument"
fi
