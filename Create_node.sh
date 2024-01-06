#PART 5

#!/bin/bash

name_of_node=$(zenity --entry --title="Node name required" --text="Please provide a name to your node : ")

if [ -n "$name_of_node" ]; then
    zenity --info --text="You've named your node: $name_of_node"
else
    zenity --error --text="No name provided."
fi



ip_of_node=$(zenity --entry --title="Ip required" --text="Please provide an ip to your node $name_of_node : ")

if [ -n "ip_of_node" ]; then
    zenity --info --text="The ip provied to $name_of_node : $ip_of_node"
else
    zenity --error --text="No ip provided."
fi


mac_of_node=$(zenity --entry --title="MAC address required" --text="Please mention the physical address / MAC address of the machine in colon-hexadecimal notation : ")

if [ -n "$mac_of_node" ]; then
    zenity --info --text="You mentioned: $mac_of_node"
else
    zenity --error --text="No MAC address/physical address mentioned."
fi



ip_of_node=$(zenity --entry --title="ip required" --text="Please provide the ip which you want it to be assigned to $name_of_node1 : ")
#read -p "Please provide the ip which you want it to be assigned to $name_of_node1 : " ip_of_node
mac_of_node=$(zenity --entry --title="ip required" --text="Please mention the mac address of $name_of_node in colon-hexadecimal notation : ")
#read -p "Please mention the mac address in of $name_of_node1 in colon-hexadecimal notation : " mac_of_node


mkdef -t node -o $name_of_node groups=all netboot=pxe ip=$ip_of_node mac=$mac_of_node provmethod=centos7.9-x86_64-netboot-compute

#echo "$ip_of_node $name_of_node $name_of_node.$domain_name" >> /etc/hosts        
#echo "nameserver $master_privateip" >> /etc/resolv.conf


makehosts
makenetworks
makedhcp -n
makedns -n
makentp
systemctl restart dhcpd

nodeset $name_of_node osimage=centos7.9-x86_64-netboot-compute

whiptail --msgbox " $name_of_node is ready, please start the machine . Press Enter to continue." 10 50
