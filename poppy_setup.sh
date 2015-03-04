#! /bin/bash

resize_p2() {
    DATE=`date +%Y.%m.%d-%H.%M`
    # this takes in consideration /dev/mmcblk0p2 as the rootfs!
    rsflog=/root/resize-$DATE-log.txt
    echo -e "\e[33mSaving partitioning log to $rsflog\e[0m"
    sleep 4

    p2_start=`fdisk -l /dev/mmcblk0 | grep mmcblk0p2 | awk '{print $2}'`
    p2_finish=$((`fdisk -l /dev/mmcblk0 | grep total | grep sectors | awk '{printf $8}'` - 1024))
    echo $p2_start
    echo $p2_finish
    fdisk /dev/mmcblk0 <<EOF &>> $rsflog
p
d
2
n
p
2
$p2_start
$p2_finish
p
w
EOF

    cat <<\EOF > /etc/init.d/resize2fs_once
#!/bin/sh
### BEGIN INIT INFO
# Provides:          resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once" &&
    resize2fs /dev/mmcblk0p2 &&
    rm /etc/init.d/resize2fs_once &&
    update-rc.d resize2fs_once remove &&
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF

  chmod +x /etc/init.d/resize2fs_once
  update-rc.d resize2fs_once defaults
  REBOOT=1

  return 0
}

# Here is the script start :

if [ `whoami` != "root" ];
then
    echo -e "\e[33mYou must run the app as root:\e[0m"
    echo -e "\e[32msudo bash $0\e[0m"
    exit 0
fi

apt-get update
apt-get install avahi-daemon passwd libnss-mdns
# Run installation scripts
echo -e "\e[33mResize your file system.\e[0m"
resize_p2

echo -e "\e[33mDefault Hostname change to \e[4mpoppy\e[0m."
echo 'poppy' > /etc/hostname
echo '127.0.0.1     poppy' >> /etc/hosts
service avahi-daemon restart

echo -e "\e[33mCreate a new user \e[4mpoppy\e[0m\e[33m with the default password \e[4mpoppy\e[0m."

useradd -m -s /bin/bash -G adm,dialout,fax,cdrom,floppy,tape,sudo,audio,dip,video,plugdev,netdev,lpadmin,fuse poppy
echo poppy:poppy | chpasswd

currentDirectory="$(pwd)/src"
if [ -f $currentDirectory/poppy_install.sh ] && [ -f $currentDirectory/poppy_launcher.sh ];
then
    chmod +x $currentDirectory/poppy_install.sh
    chmod +x $currentDirectory/poppy_launcher.sh
    (crontab -l; echo "@reboot (cd $currentDirectory; bash poppy_launcher.sh; rm poppy_launcher.sh)") | crontab
else
    echo -e "\e[31mError. Couldn't find poppy_install.sh and poppy_launcher.sh you probably must copy this script.\e[0m"
    exit 0
fi

echo -e '\e[33mNow I will reboot and continue the installation.\e[0m'
echo -e '\e[33mPlease reconnect you with:\e[0m'
echo -e '\e[32mssh poppy@poppy.local\e[0m'
echo -e '\e[33mto follow the next step of installation process.\e[0m'
echo -e "\e[33mYour new password is 'poppy'\e[0m"
reboot