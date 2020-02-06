#!/bin/bash
#
# Copyright (C) 2016 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

if [ $(id -u) -ne 0 ] ; then
	echo "ERROR: needs to be executed as root"
	exit 1
fi
model=bigboxx
arch=arm64
image_name=bigboxx.img
ubuntu_image_extra_args=
channel=candidate

if [ ! -z "$1" ] && [ "$1" == "amd64" ] ; then
	channel=stable
	arch=$1
	model=bigboxx-amd64
	image_name=bigboxx-amd64.img
fi

snap=
if [ ! -z "$2" ] ; then
	snap=$2
fi


if [ ! -z "$snap" ] ; then
	ubuntu_image_extra_args="--snap $snap"
fi

# if [ "$1" == "amd64" ] ; then
	# ubuntu-image \
	# 	--channel $channel \
	# 	-o $image_name \
	# 	$ubuntu_image_extra_args \
	# 	$model.model
# else
ubuntu-image \
	--channel $channel \
	-o $image_name \
	--snap bigboxx-kernel=latest/edge \
	--snap bigboxx-query=latest/edge \
	--snap bigboxx-totem=latest/edge \
	--snap mir-kiosk=latest/stable \
	--snap wpe-webkit-mir-kiosk=latest/stable \
	$ubuntu_image_extra_args \
	$model.model
# fi
	# --snap mir-kiosk=latest/stable \
	# --snap wpe-webkit-mir-kiosk=latest/stable \



kpartx -a $image_name
sleep 0.5

loop_path=`findfs LABEL=writable`
tmp_mount=`mktemp -d`

mount $loop_path $tmp_mount

# Migrate all systemd units from core snap into the writable area. This
# would be normally done on firstboot by the initramfs but we can't rely
# on that because we  are adding another file in there and that will
# prevent the initramfs from transitioning any files.
core_snap=$(find $tmp_mount/system-data/var/lib/snapd/snaps -name "core18*.snap")
tmp_core=`mktemp -d`
mount $core_snap $tmp_core
mkdir -p $tmp_mount/system-data/etc/systemd
cp -rav $tmp_core/etc/systemd/* \
	$tmp_mount/system-data/etc/systemd/
umount $tmp_core
rm -rf $tmp_core

# system-user assertion which gives us our test:test user we use to
# log into the system
mkdir -p $tmp_mount/system-data/var/lib/snapd/seed/assertions
cp bigboxx-user.assertion $tmp_mount/system-data/var/lib/snapd/seed/assertions

# Disable console-conf for the first boot
mkdir -p $tmp_mount/system-data/var/lib/console-conf/
touch $tmp_mount/system-data/var/lib/console-conf/complete

# Create systemd service which is running on firstboot and sets up
# various things for us.
mkdir -p $tmp_mount/system-data/etc/systemd/system
cat << 'EOF' > $tmp_mount/system-data/etc/systemd/system/devmode-firstboot.service
[Unit]
Description=Run devmode firstboot setup
After=snapd.service

[Service]
Type=oneshot
ExecStart=/writable/system-data/var/lib/devmode-firstboot/run.sh
RemainAfterExit=yes
TimeoutSec=3min
EOF

mkdir -p $tmp_mount/system-data/etc/systemd/system/multi-user.target.wants
ln -sf /etc/systemd/system/devmode-firstboot.service \
	$tmp_mount/system-data/etc/systemd/system/multi-user.target.wants/devmode-firstboot.service

mkdir $tmp_mount/system-data/var/lib/devmode-firstboot

cat << 'EOF' > $tmp_mount/system-data/var/lib/devmode-firstboot/prepare.sh
#!/bin/bash

# Description: Bigboxx Hardware Configuration
# Author: Bruno de Abreu Caceres
# Date: Jan/2020

Menu(){
clear
   echo "------------------------------------------"
   echo "    Bigboxx Hardware Config          "
   echo "------------------------------------------"
   echo
   echo "[ 1 ] Configure Network"
   echo "[ 2 ] Change Bigboxx Password"
   echo "[ 3 ] Console Shell"
   echo "[ 4 ] Reboot"
   echo "[ 5 ] Shutdown"
   echo
   echo -n "Choose the operation ? "
   read op
   case $op in
      1) Network ;;
      2) Menu ;;
      3) /bin/bash ;;
      4) sudo reboot ;;
      5) sudo shutdown -h now ;;
      *) "Unknown option." ; echo ; Menu ;;
   esac
}

Network(){
   clear
   echo "------------------------------------------"
   echo "    Network Config          "
   echo "------------------------------------------"
   echo
   echo "[ 1 ] Configure Ethernet Network Static"
   echo "[ 2 ] Configure Ethernet Network DHCP"
   echo "[ 3 ] Configure Wifi Network Static"
   echo "[ 4 ] Configure Wifi Network DHCP"
   echo "[ 5 ] Show Network Config"
   echo "[ 6 ] Return Menu"
   echo
   echo -n "Choose the operation ? "
   read op
      case $op in
      1)  
         clear
         echo "------------------------------------------"
         echo "    Configure Ethernet Network Static     "
         echo "------------------------------------------"
         echo
         echo "Enter the IP Address - Ex: 192.168.15.10"
         read ip
         echo "Enter the Gateway IP - Ex: 192.168.15.1"
         read gw
         echo "Would you like to apply the network settings ? (s/N)"
         read op
         case $op in
            s) 
            NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
network:
  ethernets:
    eth0:
      addresses: IPADDRESS
      gateway4: GATEWAY
      nameservers:
        addresses: [8.8.8.8]
      dhcp4: false
  version: 2
EOF'
sudo sed -i "s/IPADDRESS/\[$ip\/24\]/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/GATEWAY/$gw/" "/etc/netplan/00-snapd-config.yaml"
sudo netplan apply
            Network
            ;;
            N) Network ;;
            *) "Unknown option." ; echo ; Network ;;
         esac
      ;;
      2) 
         clear
         echo "------------------------------------------"
         echo "    Configure Ethernet Network DHCP       "
         echo "------------------------------------------"
         echo
         echo "Would you like to apply the network settings ? (s/N)"
         read op
         case $op in
            s) 
            NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
# This is the initial network config.
# It can be overwritten by cloud-init or console-conf.
network:
    version: 2
    ethernets:
        all-en:
            match:
                name: "en*"
            dhcp4: true
        all-eth:
            match:
                name: "eth*"
            dhcp4: true
EOF'
sudo netplan apply
            Network
            ;;
            N) Network ;;
            *) "Unknown option." ; echo ; Network ;;
         esac
      ;;

      3)  
         clear
         echo "------------------------------------------"
         echo "    Configure Wifi Network Static     "
         echo "------------------------------------------"
         echo
         echo "SSID Name"
         read ssid
         echo "Password SSID - $ssid"
         read password         
         echo "Enter the IP Address - Ex: 192.168.15.10"
         read ip
         echo "Enter the Gateway IP - Ex: 192.168.15.1"
         read gw
         echo "Would you like to apply the network settings?? (y/N)"
         read op
         case $op in
            y) 
            NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
network:
  wifis:
    wlan0:
      access-points:
        SSID:
          password: PASSWD
      addresses: IPADDRESS
      gateway4: GATEWAY
      nameservers:
        addresses: [8.8.8.8]
      dhcp4: false
  version: 2
EOF'
sudo sed -i "s/IPADDRESS/\[$ip\/24\]/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/GATEWAY/$gw/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/SSID/$ssid/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/PASSWD/$password/" "/etc/netplan/00-snapd-config.yaml"
sudo netplan generate
sudo netplan apply
            Network
            ;;
            N) Network ;;
            *) "Unknown option." ; echo ; Network ;;
         esac
      ;;
      4) 
         clear
         echo "------------------------------------------"
         echo "    Configure Wifi Network DHCP       "
         echo "------------------------------------------"
         echo
         echo "SSID Name"
         read ssid
         echo "Password SSID - $ssid"
         read password
         echo "Would you like to apply the network settings ? (s/N)"
         read op
         case $op in
            s) 
            NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
# This is the network config written by 'console-conf'
network:
  wifis:
    wlan0:
      access-points:
        SSID:
          password: PASSWD
      dhcp4: true
  version: 2
EOF'
sudo sed -i "s/SSID/$ssid/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/PASSWD/$password/" "/etc/netplan/00-snapd-config.yaml"
sudo netplan generate
sudo netplan apply
            Network
            ;;
            N) Network ;;
            *) "Unknown option." ; echo ; Network ;;
         esac
      ;;
      5) cat /etc/netplan/00-snapd-config.yaml ; read enter ; Network ;;
      *) "Unknown option." ; echo ; Menu ;;
   esac
}

Menu
EOF


cat << 'EOF' > $tmp_mount/system-data/var/lib/devmode-firstboot/run.sh
#!/bin/bash

set -e

# Don't start again if we're already done
if [ -e /writable/system-data/var/lib/devmode-firstboot/complete ] ; then
	exit 0
fi

echo "Start devmode-firstboot $(date -Iseconds --utc)"

if [ "$(snap managed)" = "true" ]; then
	echo "System already managed, exiting"
	exit 0
fi

# no changes at all
while ! snap changes ; do
	echo "No changes yet, waiting"
	sleep 1
done

while snap changes | grep -qE '(Do|Doing) .*Initialize system state' ;  do
	echo "Initialize system state is in progress, waiting"
	sleep 1
done

if [ -n "$(snap known system-user)" ]; then
	echo "Trying to create known user"
	snap create-user --known --sudoer
fi

echo "Hidden cursor"
sed -i "/cursor=software/c cursor=null" /var/snap/mir-kiosk/current/miral-kiosk.config  
# snap set mir-kiosk cursor=none &

# echo "Orientation: Inverted"
#sed -i '/orientation/d' /var/snap/mir-kiosk/current/miral-kiosk.display
#echo "        orientation: inverted    # {normal, left, right, inverted}, defaults to normal" >>/var/snap/mir-kiosk/current/miral-kiosk.display

echo "Desabling Bluetooth"
sed -i "/dtoverlay=vc4-fkms-v3d,cma-256/c dtoverlay=vc4-fkms-v3d,cma-256,pi3-disable-bt" /boot/uboot/config.txt

# snap disable wpe-webkit-mir-kiosk
# sleep 5

# snap disable mir-kiosk
# sleep 5

echo "Configuring Browser"
snap set wpe-webkit-mir-kiosk url="http://localhost:3002" &

# echo "Update Snaps"
# snap refresh bigboxx-kernel --devmode &
# snap refresh bigboxx-query --devmode &
# snap refresh bigboxx-totem --devmode &
# snap refresh mir-kiosk &
# snap refresh wpe-webkit-mir-kiosk &

chmod +x /writable/system-data/var/lib/devmode-firstboot/prepare.sh
usermod -s /writable/system-data/var/lib/devmode-firstboot/prepare.sh bigboxx

# Enable console-conf again
rm /writable/system-data/var/lib/console-conf/complete

# Mark us done
touch /writable/system-data/var/lib/devmode-firstboot/complete

# Reboot the system as its now prepared for the user
shutdown -r now

EOF

chmod +x $tmp_mount/system-data/var/lib/devmode-firstboot/run.sh

umount $tmp_mount
kpartx -d $image_name
rm -rf $tmp_mount