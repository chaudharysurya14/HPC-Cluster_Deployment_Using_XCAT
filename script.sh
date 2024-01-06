#!/bin/bash

yum install gnome-terminal -y
yum install zenity -y
zenity --info --text "Welcome to the xCAT Setup Wizard. Click OK to continue." --title "xCAT Setup" --width=400


#Disable Firewall
systemctl stop firewalld.service; systemctl stop firewalld
systemctl disable firewalld.service; systemctl disable firewalld

#Disable SELINUX
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

#Disable DHCP on the interface
private_interface=$(zenity --entry --title="Private network's interface required" --text="Please mention the interface of private network : ")
mkdir -p /root/inputs
touch /root/inputs/private_interface
echo "$private_interface" > /root/inputs/private_interface


#read -p "Please mention the interface of private network : " private_interface
#sed -i '/BOOTPROTO/d' /etc/sysconfig/network-scripts/ifcfg-$private_interface
#echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$private_interface

#Taking inputs Hostname, IP, Domain name

default_hostname="master"
hostname_master=$(zenity --entry --title="Hostname Setup" --text="Please provide a hostname for your master:" --entry-text="$default_hostname")

if [ -n "$hostname_master" ]; then
    echo "Entered hostname: $hostname_master"
else
    echo "Hostname entry canceled."
fi

touch /root/inputs/hostname_master
echo "$hostname_master" > /root/inputs/hostname_master
#read -p "Provide a hostname to your master : " hostname_master


privateip_network=$(ip a show dev $private_interface | grep -oP 'inet \K[\d.]+')
echo "nameserver $privateip_network" >> /etc/resolv.conf    #this command not running in bash
touch /root/inputs/private_ip
echo "$privateip_network" > /root/inputs/private_ip

zenity \
--info \
--text="current ip of $private_interface is $privateip_network.\n DO NOT CHANGE THE IP" \
--title="ip of $private_interface" \
--ok-label="OK"
                                   
#whiptail --msgbox "Your current Private ip is $privateip_network. Press Enter & retype the same ip LOL." 10 50
#read -p "Retype Private ip of your Master Node : " master_privateip

default_domain="example.com"
domain_name=$(zenity --entry --title="Domain Name Setup" --text="Please provide a domain name:" --entry-text="$default_domain")

if [ -n "$domain_name" ]; then
    # Show a confirmation dialog using zenity
    zenity --question --title="Confirm Domain Name" --text="Are you sure you want to set the domain name to:\n$domain_name?"
    
    # Check the exit status of zenity (0 for Yes, 1 for No)
    if [ $? -eq 0 ]; then
        # User confirmed, store the value in a file
        echo "$domain_name" > /root/inputs/domain_name
        echo "Entered domain name '$domain_name' saved."
        
        # Continue with the rest of your script logic
    else
        # User canceled the confirmation, so do nothing
        echo "Domain name entry canceled."
    fi
else
    # User canceled or did not provide a domain name
    echo "Domain name entry canceled."
fi

touch /root/inputs/domain_name
echo "$domain_name" > /root/inputs/domain_name               
hostnamectl set-hostname $hostname_master.$domain_name                                                             

#state_file="script_state.txt"

#if [ -e "$state_file" ]; then
    # Continue from the saved state
#    saved_line=$(cat "$state_file")
#    echo "Resuming from line: $saved_line"
    # Continue your script logic here starting from the saved line

    # For demonstration, let's say the script is paused at line 10
    # Uncomment the line below to simulate continuing from line 11
#     ((saved_line++))
#else
#    echo "Starting the script"
#    saved_line=1
#fi

# Your script logic here
#for ((i = $saved_line; i <= 20; i++)); do
#    echo "Processing line: $i"
    # Save the current line to the state file before restarting
#    echo "$i" > "$state_file"

    # Simulate a restart
#    if [ "$i" -eq 10 ]; then
#        echo "Restarting the script"
#        exec bash
#    fi
#done

# Cleanup: remove the state file at the end
#rm "$state_file"
#echo "Script finished"



#Changing network
#privateip_network=$(ip a show dev $private_interface | grep -oP 'inet \K[\d.]+')
#read -p "Provide Private ip to your Master Node : " master_privateip
#ip addr add $master_privateip/255.255.255.0 dev ens34
#sed -i 's/IPADDR=$privateip_network/IPADDR=$master_privateip/g' /etc/sysconfig/network-scripts/ifcfg-$private_interface
#echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$private_interface
#ifdown $private_interface
#ifup $private_interface

#Assigning values
echo "$privateip_network $hostname_master $hostname_master.$domain_name" >> /etc/hosts
echo "nameserver $privateip_network" >> /etc/resolv.conf    #this command not running in bash
#sed -i "\$a nameserver $ip" /etc/resolv.conf #try, this might run in bash
#echo "nameserver $privateip_network" | sudo tee -a /etc/resolv.conf      #This runs but you need to enter password

#whiptail --msgbox "Machine needs a reboot, please press Enter to continue." 10 50



# Make sure the scripts are executable


chmod +x vm_xCAT.sh bm_xCAT.sh

# Prompt the user for a hostname
# Present the user with a choice using Zenity
choice=$(zenity --list --text "Select an option:" --radiolist --column "Select" --column "Option" TRUE "Virtual Machine" FALSE "Bare-metal")

# Function to run a script and close the terminal afterward
run_script_and_close_terminal() {
    gnome-terminal -- bash -c "$1; exec bash"
}

case "$choice" in
    "Virtual Machine")
        run_script_and_close_terminal "./vm_xCAT.sh"
        ;;
    "Bare-metal")
        run_script_and_close_terminal "./bm_xCAT.sh"
        ;;
esac
