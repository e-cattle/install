#!/bin/bash
#
# Bash script to install E-Cattle Bigboxx
#
# Author:
#   Bruno A. Caceres <brunoacaceres@gmail.com>
#
# Description:
#   script to install E-Cattle Bigboxx
#
# Usage:
#
# curl -sL https://github.com/e-cattle/install/install.sh | bash -
#   or
# wget -qO- https://github.com/e-cattle/install/install.sh | bash -
#

#Global Variables
#URL_SCRIPT="http://172.16.254.254:5000"
URL_SCRIPT="https://raw.githubusercontent.com/e-cattle/install/master"
URL_GIT="git@git.cnpgc.embrapa.br:e-cattle"
PROJECT="/opt/bigboxx"


echo '------------------------------------------------------------------------'
echo '=> Installing Bigboxx'
echo '------------------------------------------------------------------------'

# -----------------------------------------------------------------------------
# => Habilitando Configuracoes de rede
# -----------------------------------------------------------------------------
#echo
#echo '=> Habilitando configuracoes de Rede'
#echo -e "auto eth0 \niface eth0 inet static\n address 172.16.254.1\n netmask 255.255.255.0\n gateway 172.16.254.254\n dns-nameservers 8.8.8.8" | sudo tee /etc/network/interfaces.d/eth0
#echo -e "auto eth0 \niface eth0 inet static\n address 172.16.254.1\n netmask 255.255.255.0" | sudo tee /etc/network/interfaces.d/eth0
#sudo systemctl restart networking
#echo 'Done.'

# -----------------------------------------------------------------------------
# => Enable SSH Service
# -----------------------------------------------------------------------------
echo
echo '=> Start and Enable SSH Service'
sudo systemctl start ssh 
sudo systemctl enable ssh
echo 'Done.'

# -----------------------------------------------------------------------------
# => Update apt repository and upgrade Raspberry
# -----------------------------------------------------------------------------
echo
echo '=> Update apt repository'
sudo apt-get update -qq
echo '=> Upgrade Raspberry'
sudo apt-get dist-upgrade upgrade -y
echo 'Done.'

# -----------------------------------------------------------------------------
# => Installing Basics packages to Graphical Interface, Utilities and Chromium Browser
# -----------------------------------------------------------------------------
echo
echo '=> Installing Basics packages with Graphical Interface, Utilities and Chromium Browser'
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y --no-install-recommends openbox-lxde-session lightdm lxterminal \
    chromium-browser git nodejs=8.15.0-1nodesource1 mongodb-server vim
echo 'Done.'

# -----------------------------------------------------------------------------
# => Enable autologin, graphical interface and autostart Chromium
# -----------------------------------------------------------------------------
echo
echo '=> Enable autologin'
sudo sed -i "/#autologin\-user=/c autologin\-user=pi" /etc/lightdm/lightdm.conf
echo 'Done.'
echo
echo '=> Enable Graphical Interface'
sudo systemctl set-default graphical.target
echo 'Done.'
echo
echo '=> Configuring Chromium autostart'
mkdir -p $HOME/.config/lxsession/LXDE
curl $URL_SCRIPT/autostart --output $HOME/.config/lxsession/LXDE/autostart

# -----------------------------------------------------------------------------
# => Disable services not used
# -----------------------------------------------------------------------------
echo
echo '=> Disable services not used'
SERVICES="bluetooth alsa-restore dhcpcd hciuart "
for SERVICE in $SERVICES
do
    sudo systemctl stop $SERVICE
    sudo systemctl disable $SERVICE
    sudo systemctl daemon-reload
done
echo 'Done.'

# -----------------------------------------------------------------------------
# => Configurando Chave SSH para acesso ao Repo
# -----------------------------------------------------------------------------
#echo
#echo '=> Configurando chave para acesso ao GIT'
#mkdir -m 700 $HOME/.ssh
#curl $URL_SCRIPT/ssh --output $HOME/.ssh/id_rsa
#chmod 600 $HOME/.ssh/id_rsa
#echo 'Done.'

# -----------------------------------------------------------------------------
# => Cloning git projects
# -----------------------------------------------------------------------------
echo
echo '=> Create folder project'
sudo mkdir $PROJECT
sudo chown pi:pi $PROJECT
echo 'Done.'
echo

cd $PROJECT
APPS="kernel api manager"
for MODULE in $APPS
do
    echo
    echo "=> Cloning $MODULE with project Bigboxx"
    cd $PROJECT
    git clone $URL_GIT/$MODULE.git
    cd $MODULE
    npm install
    echo
    echo "=> Enable service $MODULE"
    sudo curl $URL_SCRIPT/$MODULE.service --output /lib/systemd/system/$MODULE.service
    sudo systemctl daemon-reload
    sudo systemctl enable $MODULE
    sudo systemctl start $MODULE
    #npm update
done
echo 'Done.'