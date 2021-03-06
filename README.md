# Raspberry AP/Client
**A simple script utility to easily manage AP mode and Client mode on a Raspberry Pi**


The script aims to reduce the time needed to set up a bridged Access Point on a Raspberry Pi and to easily manage its state.
Since the Access Point does not allow to use wlan0 interface and so the WiFi, the script also offers a centralized way to manage the commutation between Client and AP mode. 


## Features

- Instantly setup a bridged AP
- Manage the state of the AP
- Manage the state of wlan0 interface

## Description
Setting up an AP could be a very time-spending activity, especially for beginnners.  
Also managing the state of the AP and the commutation to client mode could be very confusing with such a big variety of choice. 
This script is primarily intended to be used as a command line utility, or called via code.


## Requirements

The script requires [hostapd](https://wiki.gentoo.org/wiki/Hostapd) to run.     
Install hostapd

```sh
sudo apt install hostapd
```

Finally be sure to configure WLAN Country in raspi-config -> Localisation Options.   
To run raspi config:

```sh
sudo raspi-config
```  
**It seems that hostapd configuration is not working properly on systems which use [NetworkManager](https://wiki.archlinux.org/index.php/NetworkManager).**    
**It is strongly recommended to use Raspbian** 
 

## Usage
In the script directory:

* Setup the AP (required for working properly)**(reboot required)**
    ```sh
    sudo ./ap.sh setup <your_contry_code>
    ```
    Example
     ```sh
    sudo ./ap.sh setup setup gb
    ```
* Turn on/off the AP
    ```sh
    sudo ./ap.sh up <ssid>
    ```
    ```sh
    sudo ./ap.sh down
    ```
    **To correctly execute any other command, you have to manually turn off the AP, if on.**
    **This is also appliable if the Raspberry shutdown unexpectedly when AP is on**
    
* Turn on/off WiFi connection in client mode
    ```sh
    sudo ./client.sh up
    ```
    ```sh
    sudo ./client.sh down
    ```
