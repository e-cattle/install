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

channel=edge
if [ ! -z "$1" ] ; then
	channel=$1
fi

snap=
if [ ! -z "$2" ] ; then
	snap=$2
fi

model=bigboxx
arch=arm64
image_name=bigboxx.img
ubuntu_image_extra_args=

if [ ! -z "$snap" ] ; then
	ubuntu_image_extra_args="--snap $snap"
fi

ubuntu-image \
	--channel $channel \
	-o $image_name \
	$ubuntu_image_extra_args \
	--snap mir-kiosk=latest/stable \
	--snap wpe-webkit-mir-kiosk=latest/beta \
	$model.model

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

echo "Orientation: Inverted"
#sed -i '/orientation/d' /var/snap/mir-kiosk/current/miral-kiosk.display
#echo "        orientation: inverted    # {normal, left, right, inverted}, defaults to normal" >>/var/snap/mir-kiosk/current/miral-kiosk.display

echo "Desabling Bluetooth"
sed -i "/dtoverlay=vc4-fkms-v3d,cma-256/c dtoverlay=vc4-fkms-v3d,cma-256,pi3-disable-bt" /boot/uboot/config.txt

echo "Configuring Browser"
snap set wpe-webkit-mir-kiosk url="http://localhost:3002" &

echo "Upgrade modules Bigboxx"
snap refresh bigboxx-kernel --devmode &
snap refresh bigboxx-query --devmode &
snap refresh bigboxx-totem --devmode &
snap refresh bigboxx-lora --devmode &

# Enable console-conf again
rm /writable/system-data/var/lib/console-conf/complete

# Mark us done
touch /writable/system-data/var/lib/devmode-firstboot/complete

# Reboot the system as its now prepared for the user
sudo shutdown -r now

EOF

chmod +x $tmp_mount/system-data/var/lib/devmode-firstboot/run.sh

umount $tmp_mount
kpartx -d $image_name
rm -rf $tmp_mount