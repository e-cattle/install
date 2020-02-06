#!/bin/bash

# Description: Prepare Bigboxx
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