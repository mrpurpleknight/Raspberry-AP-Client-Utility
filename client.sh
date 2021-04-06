#!/bin/bash

function up() {
    ifconfig wlan0 up
}

function down() {
    ifconfig wlan0 down
}

if [ "$1" == "up" ]; then
    up
elif [ "$1" == "down" ]; then
    down
else
    echo "Invalid option: No suitable option"
fi
