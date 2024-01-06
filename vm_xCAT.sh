#xCAT for VM

#!/bin/bash


#Updating yum and Utilities
yum install zenity -y
yum install xterm -y
yum install ntp -y
yum update -y
yum install yum-utils -y
wget -P /etc/yum.repos.d https://xcat.org/files/xcat/repos/yum/latest/xcat-core/xcat-core.repo --no-check-certificate
wget -P /etc/yum.repos.d https://xcat.org/files/xcat/repos/yum/xcat-dep/rh7/x86_64/xcat-dep.repo --no-check-certificate
yum install epel-release -y
yum clean all
yum makecache
yum install xCAT -y


#SOURCE
xcat_source="source /etc/profile.d/xcat.sh"
eval "$xcat_source"
source /etc/profile.d/xcat.sh

#xcat_dot=". /etc/profile.d/xcat.sh"
#eval "$xcat_dot"
#. /etc/profile.d/xcat.sh



#YOU HAVE TO MANUALLY SOURCE  /etc/profile.d/xcat.sh
#hostname_master=$(zenity --entry --title="source /etc/profile.d/xcat.sh" --text="xCAT has been installed successfully, type the command shown on the title on the terminal to unlock xCAT.")
#whiptail --msgbox "xCAT has been installed successfully, please copy "source /etc/profile.d/xcat.sh" and paste it on the terminal, to unlock xCAT." 10 50


#source_command=$(zenity --entry --title "Unlocking xCAT" --text "Please type source /etc/profile.d/xcat.sh and click OK to unlock xCAT")
#output=$(gnome-terminal -- bash -c "$source_command; echo -e '\nPress Enter to exit...'; read")
#zenity --text-info --title "Command Output" --width 800 --height 400 --filename=<(echo "$output")

whiptail --msgbox "xCAT has been installed successfullly. Press Enter to continue." 10 50



#PART 3


domain_name=`cat /root/inputs/domain_name`
hostname_master=`cat /root/inputs/hostname_master`
private_interface=`cat /root/inputs/private_interface`
private_ip=`cat /root/inputs/private_ip`

chdef -t site domain=$domain_name
dhcpinterfaces="chdef -t site dhcpinterfaces='$hostname_master|$private_interface'"
eval "$dhcpinterfaces"
#worker_password=$(zenity --entry --title="Password" --text="Provide a common password for all worker nodes : ")
#read -p "Provide Password for worker node : " worker_password
#passwd="chtab key=system passwd.username=root passwd.password=$worker_password"
#eval "$passwd"
#chtab key=system passwd.username=root passwd.password=$worker_password
makedhcp -n
makedns -n
makentp
systemctl restart dhcpd


#PART 4


wget http://mirrors.nxtgen.com/centos-mirror/7.9.2009/isos/x86_64/CentOS-7-x86_64-DVD-2009.iso
copycds CentOS-7-x86_64-DVD-2009.iso
genimage centos7.9-x86_64-netboot-compute

touch /install/netboot/compute.synclists
echo "/etc/passwd -> /etc/passwd" >> /install/netboot/compute.synclist
echo "/etc/group -> /etc/group" >> /install/netboot/compute.synclist
echo "/etc/shadow -> /etc/shadow" >> /install/netboot/compute.synclist

path_of_computelist="\"/install/netboot/compute.synclists\""
compute_list="chdef -t osimage centos7.9-x86_64-netboot-compute synclists=$path_of_computelist"
eval "$compute_list"

chdef -t osimage centos7.9-x86_64-netboot-compute synclists="/install/netboot/compute.synclists" #This does not run in bash, run this command manually on terminal
#packimage centos7.9-x86_64-netboot-compute


