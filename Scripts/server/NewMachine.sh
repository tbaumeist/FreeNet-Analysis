#!/bin/bash

# ask for computer name
define compName
echo -n "Enter computer name: "
read compName
echo ""

# ask for static IP
define staticIP
echo -n "Enter static IP: "
read staticIP
echo ""

# write network interface
networkInterfaceFile="/etc/network/interfaces"
echo "auto lo" > $networkInterfaceFile
echo "iface lo inet loopback" >> $networkInterfaceFile
echo "" >> $networkInterfaceFile
echo "auto eth0" >> $networkInterfaceFile
echo "# iface eth0 inet dhcp" >> $networkInterfaceFile
echo "iface eth0 inet static" >> $networkInterfaceFile
echo -e "\taddress $staticIP" >> $networkInterfaceFile
echo -e "\tnetmask 255.255.255.0" >> $networkInterfaceFile
echo -e "\tnetwork 192.168.0.0" >> $networkInterfaceFile
echo -e "\tbroadcast 192.168.0.255" >> $networkInterfaceFile
echo -e "\tgateway 192.168.0.1" >> $networkInterfaceFile
echo "" >> $networkInterfaceFile

#write computer name
comptNameFile="/etc/hostname"
echo "$compName" > $comptNameFile

