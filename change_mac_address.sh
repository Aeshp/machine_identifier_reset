#!/bin/bash  

# hii it will list all avliable network interfaces like your wifi or ethernet cards you have and in input add yours.
ip -o link show | awk -F': ' '{print $2}'
read -p "Enter interface name from the list above: " IFACE

#this command finds your current MAC address and saves it as a backup
ip link show "$IFACE" | awk '/ether/ {print $2}' > ~/orig_mac.txt

#if macchanger is installed then well otherwise it'll install.
if ! command -v macchanger &> /dev/null; then
    sudo apt update && sudo apt install -y macchanger
fi


#alright here your internet will get disconnected for some moment.
sudo ip link set dev "$IFACE" down
#it'll change the mac address of that interface card which you have selected.
sudo macchanger -r "$IFACE"
#take up internet again
sudo ip link set dev "$IFACE" up

#It displays the new MAC address on the screen so you can confirm that the script worked.
echo -n "New MAC: "
ip link show "$IFACE" | awk '/ether/ {print $2}'
