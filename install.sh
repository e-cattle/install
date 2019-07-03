#!/bin/bash
#
# Bash script to install e-Cattle BigBoxx middleware
#
# Authors:
#   Bruno A. Caceres <brunoacaceres@gmail.com>
#   Camilo Carromeu <camilo.carromeu@embrapa.br>
#
# Description:
#   Script to install e-Cattle BigBoxx middleware in Ubuntu Core system.
#
# Usage:
#   mkfifo pipe && nc https://raw.githubusercontent.com/e-cattle/install/master/install.sh 443 <pipe | /bin/bash &>pipe
#

echo "e-Cattle BigBoxx"
echo "Starting script..."

echo "Updating snaps..."

sudo snap refresh

echo "Done!"

echo "All done! Rebooting system..."

sudo reboot
