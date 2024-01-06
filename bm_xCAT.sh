#xCAT installation on bare metal


#!/bin/bash


#Updating yum and Utilities
yum install zenity -y
yum install xterm -y
yum install ntp -y
yum update -y
yum install yum-utils -y
yum install epel-release -y


#Making xcat directory which will contain xcat-core and xcat-dep
mkdir -p ~/xcat
cd ~/xcat/

#downloading xCAT
wget https://raw.githubusercontent.com/xcat2/xcat-core/master/xCAT-server/share/xcat/tools/go-xcat -O - >/tmp/go-xcat
chmod +x /tmp/go-xcat

#This will install xcat
/tmp/go-xcat install -y
wget https://xcat.org/files/xcat/xcat-core/2.16.x_Linux/xcat-core/xcat-core-2.16.5-linux.tar.bz2
wget https://xcat.org/files/xcat/xcat-dep/2.x_Ubuntu/?C=M;O=D
wget https://xcat.org/files/xcat/xcat-dep/2.x_Linux/xcat-dep-202212061505.tar.bz2

#Extracting xcat-core
tar xvf xcat-core-2.16.5-linux.tar.bz2
tar jxvf xcat-dep-202212061505.tar.bz2
cd ~/xcat/xcat-core
./mklocalrepo.sh

# Inside xcat-dep

cd ~/xcat/xcat-dep/
cd rh7
cd ppc64le/
./mklocalrepo.sh


#yum install xCAT -y
#chmod 777 /etc/profile.d/xcat.sh


#SOURCE
xcat_source="source /etc/profile.d/xca+t.sh"
eval "$xcat_source"
source /etc/profile.d/xcat.sh

#xcat_dot=". /etc/profile.d/xcat.sh"
#eval "$xcat_dot"
#. /etc/profile.d/xcat.sh



#YOU HAVE TO MANUALLY SOURCE  /etc/profile.d/xcat.sh
#hostname_master=$(zenity --entry --title="source /etc/profile.d/xcat.sh" --text="xCAT has #been installed successfully, type the command shown on the title on the terminal to unlock xCAT.")
whiptail --msgbox "xCAT has been installed successfully, Press OK to continue." 10 50


#PART 3


domain_name=`cat /root/inputs/domain_name`
hostname_master=`cat /root/inputs/hostname_master`
private_interface=`cat /root/inputs/private_interface`
private_ip=`cat /root/inputs/private_ip`

chdef -t site domain=$domain_name
dhcpinterfaces="chdef -t site dhcpinterfaces='$hostname_master|$private_interface'"
eval "$dhcpinterfaces"
worker_password=$(zenity --entry --title="Password" --text="Provide a common password for all worker nodes : ")
#read -p "Provide Password for worker node : " worker_password
passwd="chtab key=system passwd.username=root passwd.password=$worker_password"
eval "$passwd"
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
