#!/bin/bash

# Description: Prepare Bigboxx
# Author: Bruno de Abreu Caceres
# Date: Jan/2020

#Pre-requisites

if [ ! -f /home/bigboxx/.ssh/id_rsa  ] ; then

   echo "Hidden cursor"
   snap set mir-kiosk cursor="none"   

   echo "Desabling Bluetooth"
   sudo sed -i "/dtoverlay=vc4-fkms-v3d,cma-256/c dtoverlay=vc4-fkms-v3d,cma-256,pi3-disable-bt" /boot/uboot/config.txt

   echo "Configuring Browser"
   snap set wpe-webkit-mir-kiosk url="http://localhost:3002"

   echo "SSH Key Generate"
   ssh-keygen -t rsa -N '' -f /home/bigboxx/.ssh/id_rsa ; cat /home/bigboxx/.ssh/id_rsa.pub > /home/bigboxx/.ssh/authorized_keys ; chmod 600 /home/bigboxx/.ssh/authorized_keys
   
   echo "Blocking snap updates"
   sudo bash -c 'echo "127.0.0.1 localhost" > /etc/hosts'
   sudo bash -c 'echo "127.1.1.1 search.apps.ubuntu.com api.snapcraft.io " >> /etc/hosts'
fi

Menu(){
clear
   echo "------------------------------------------"
   echo "    Bigboxx Hardware Config          "
   echo "------------------------------------------"
   echo
   echo "[ 1 ] Configure Network"
   echo "[ 2 ] Configure Screen"
   echo "[ 3 ] Update Bigboxx Modules"
   echo "[ 4 ] Console Shell"
   echo "[ 5 ] Apply Configurations and Reboot"
   echo "[ 6 ] Shutdown"
   echo
   echo -n "Choose the operation ? "
   read op
   case $op in
      1) Network ;;
      2) Screen ;;
      3) Update ;;
      4) /bin/bash ;;
      5) sudo reboot ;;
      6) sudo shutdown -h now ;;
      *) "Unknown option." ; echo ; Menu ;;
   esac
}

Network(){
   clear
   echo "------------------------------------------"
   echo "    Network Config          "
   echo "------------------------------------------"
   echo
   echo "[ 0 ] Return Main Menu"
   echo "[ 1 ] Configure Ethernet Network Static"
   echo "[ 2 ] Configure Ethernet Network DHCP - (Config Default)"
   echo "[ 3 ] Configure Wifi Network Static"
   echo "[ 4 ] Configure Wifi Network DHCP"
   echo "[ 5 ] Show Network Config"
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
         echo -n "Enter the IP Address - Ex: 192.168.15.10: "
         read ip
         echo -n "Enter the Gateway IP - Ex: 192.168.15.1: "
         read gw
         echo -n "Enter the DNS IP - Ex: 192.168.15.1, 8.8.8.8: "
         read dns
         echo -n "(Restart is required) - Would you like to apply the network settings ? (y/N): "
         read op
         case $op in
            y) 
            # NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            # sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
network:
  ethernets:
    eth0:
      addresses: IPADDRESS
      gateway4: GATEWAY
      nameservers:
        addresses: [DNS]
      dhcp4: false
  version: 2
EOF'
sudo sed -i "s/IPADDRESS/\[$ip\/24\]/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/GATEWAY/$gw/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/DNS/$dns/" "/etc/netplan/00-snapd-config.yaml"
sudo netplan apply
Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;
      2) 
         clear
         echo "------------------------------------------"
         echo "    Configure Ethernet Network DHCP       "
         echo "------------------------------------------"
         echo
         echo -n "(Restart is required) - Would you like to apply the network settings ? (y/N): "
         read op
         case $op in
            y) 
            # NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            # sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
sudo bash -c 'cat << 'EOF' > /etc/netplan/00-snapd-config.yaml
# This is the initial network config.
# It can be overwritten by cloud-init or console-conf.
network:
    version: 2V
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
Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;

      3)  
         clear
         echo "------------------------------------------"
         echo "    Configure Wifi Network Static     "
         echo "------------------------------------------"
         echo
         echo -n "SSID Name: "
         read ssid
         echo -n "Password SSID - $ssid: "
         read password         
         echo -n "Enter the IP Address - Ex: 192.168.15.10: "
         read ip
         echo -n "Enter the Gateway IP - Ex: 192.168.15.1: "
         read gw
         echo -n "Enter the DNS IP - Ex: 192.168.15.1, 8.8.8.8s: "
         read dns         
         echo -n "(Restart is required) - Would you like to apply the network settings ? (y/N): "
         read op
         case $op in
            y) 
            # NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            # sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
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
        addresses: [DNS]
      dhcp4: false
  version: 2
EOF'
sudo sed -i "s/IPADDRESS/\[$ip\/24\]/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/GATEWAY/$gw/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/SSID/$ssid/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/PASSWD/$password/" "/etc/netplan/00-snapd-config.yaml"
sudo sed -i "s/DNS/$dns/" "/etc/netplan/00-snapd-config.yaml"
sudo netplan generate
sudo netplan apply
Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;
      4) 
         clear
         echo "------------------------------------------"
         echo "    Configure Wifi Network DHCP       "
         echo "------------------------------------------"
         echo
         echo -n "SSID Name: "
         read ssid
         echo -n "Password SSID - $ssid: "
         read password
         echo -n "(Restart is required) - Would you like to apply the network settings ? (y/N): "
         read op
         case $op in
            y) 
            # NOW=$(date +"%Y-%m-%d-%H-%M-%S")
            # sudo mv  /etc/netplan/00-snapd-config.yaml /home/bigboxx/00-snapd-config-$NOW.yaml
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
Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;
      5) 
      clear  
      echo "------------------------------------------"
      echo "    Network Config                        "
      echo "------------------------------------------"
      echo      
      cat /etc/netplan/00-snapd-config.yaml ; echo ; echo -n "Press ENTER key to continue... " ; read anykey ; Menu ;;
      *) "Unknown option." ; echo ; Menu ;;
   esac
}

Screen(){
   clear
   echo "------------------------------------------"
   echo "    Screen Config          "
   echo "------------------------------------------"
   echo
   echo "[ 0 ] Return Main Menu"
   echo "[ 1 ] Screen - Normal - (Config Default)"
   echo "[ 2 ] Screen - Inverted"
   echo "[ 3 ] Show Screen Config"
   echo
   echo -n "Choose the operation ? "
   read op
   case $op in
      1)
         echo -n "(Restart is required) - Would you like to apply the screen settings ? (y/N): "
         read op
         case $op in
            y)
               sudo sed -i '/orientation/d' /var/snap/mir-kiosk/current/miral-kiosk.display
               sudo bash -c 'echo "        orientation: normal    # {normal, left, right, inverted}, defaults to normal" >>/var/snap/mir-kiosk/current/miral-kiosk.display'
               Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;
      2)
         echo -n "(Restart is required) - Would you like to apply the screen settings ? (y/N): "
         read op
         case $op in
            y)
               sudo sed -i '/orientation/d' /var/snap/mir-kiosk/current/miral-kiosk.display
               sudo bash -c 'echo "        orientation: inverted    # {normal, left, right, inverted}, defaults to normal" >>/var/snap/mir-kiosk/current/miral-kiosk.display'
               Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
      ;;
      3) 
      clear 
      echo "------------------------------------------"
      echo "    Screen Config                         "
      echo "------------------------------------------"
      echo      
      cat /var/snap/mir-kiosk/current/miral-kiosk.display ; echo ; echo -n "Press ENTER key to continue... " ; read anykey ; Menu ;;
      *) "Unknown option." ; echo ; Menu ;;
   esac  
}

Update(){
         clear
         echo -n "Would you like to update all Bigboxx modules ? (y/N): "
         read op
         case $op in
            y)
               sudo bash -c 'echo "127.0.0.1 localhost" > /etc/hosts'
               snap refresh bigboxx-kernel --devmode
               snap refresh bigboxx-query --devmode
               snap refresh bigboxx-totem --devmode
               snap refresh
               sudo bash -c 'echo "127.0.0.1 localhost" > /etc/hosts'
               sudo bash -c 'echo "127.1.1.1 search.apps.ubuntu.com api.snapcraft.io " >> /etc/hosts'
               Menu
            ;;
            N) Menu ;;
            *) "Unknown option." ; echo ; Menu ;;
         esac
}

Menu