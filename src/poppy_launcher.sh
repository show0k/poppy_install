#! /bin/bash

if [ `whoami` != "root" ];
then
    echo "You must run the app as root:"
    echo "sudo bash $0"
    exit 0
fi


wget https://github.com/nicolas-rabault/poppy_install/blob/master/src/poppy_logo
mv poppy_logo /home/poppy_logo
sed -i /poppy_logo/d /home/poppy/.bashrc
echo cat /home/poppy_logo >> /home/poppy/.bashrc
echo 'Starting the Poppy environement installation' >> /home/poppy/install_log
echo tail -f /home/poppy/install_log >> /home/poppy/.bashrc

# Update needed apps.
echo 'Update your system.'
apt-get clean >> /home/poppy/install_log
apt-get update >> /home/poppy/install_log
apt-get upgrade -y >> /home/poppy/install_log
apt-get dist-upgrade -y >> /home/poppy/install_log
apt-get -y install  axel wget unzip whiptail python-pip python-opencv guvcview \
                    xz-utils libportaudio0 libportaudio2 libportaudiocpp0 \
                    portaudio19-dev python-setuptools libnss-mdns curl git i2c-tools \
                    make build-essential libssl-dev zlib1g-dev libbz2-dev \
                    libreadline-dev libsqlite3-dev wget llvm python-pyaudio >> /home/poppy/install_log

#pypot installer example
su poppy
    wget https://github.com/nicolas-rabault/poppy_install/blob/master/src/poppy_install.sh
    bash ./poppy_install.sh  >> /home/poppy/install_log &
    PID=$!
    wait $PID
exit


# Remove instalation at startup
sed -i /install_log/d /home/poppy/.bashrc
crontab -r

echo 'System install complete!' >> /home/poppy/install_log
echo "Please share your experiences with the community : https://forum.poppy-project.org/"  >> /home/poppy/install_log
