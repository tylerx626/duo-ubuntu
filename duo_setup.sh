#!/bin/bash

#This script will download, install, and configure Duo MFA for Ubuntu Servers. Only tested on 24.04 LTS.
#Official instructions here https://duo.com/docs/duounix#install-pam_duo
#run all as sudo

#install requirements
sudo apt-get update
sudo apt-get install -y build-essential libpam-dev libssl-dev wget


#download latest Duo version
if [ test -f duo_unix-latest.tar.gz ]
then
    echo "File duo_unix-latest.tar.gz exists"
else
    echo "Downloaded latest duo_unix file"
    wget https://dl.duosecurity.com/duo_unix-latest.tar.gz
fi

#check if install directory exists and mkdir if not
if [ -d "/opt/duo_unix_latest" ] 
then
    echo "Directory /opt/duo_unix_latest exists." 
else
    echo "Error: Directory /opt/duo_unix_latest/ does not exist."
    mkdir /opt/duo_unix_latest
fi

#extract downloaded tarball and change directory 
tar zxf duo_unix-latest.tar.gz -C /opt/duo_unix_latest

#find the directory path for the latest version after it extracted
FOUND_PATH=$(find /opt/duo_unix_latest -type d -name "duo_unix-*" 2>/dev/null)

echo "Found directory: $FOUND_PATH"
cd $FOUND_PATH

#build and install duo_unix with PAM support
#$FOUND_PATH/configure --with-pam --prefix=/usr && make -C /opt/duo_unix_latest && sudo make -C /opt/duo_unix_latest install
./configure --with-pam --prefix=/usr && make && sudo make install

#Create /etc/apt/sources.list.d/duosecurity.list with the following contents:
echo "deb [trusted=yes arch=amd64] https://pkg.duosecurity.com/Ubuntu noble main" >> /etc/apt/sources.list.d/duosecurity.list deb 

curl -s https://duo.com/DUO-GPG-PUBLIC-KEY.asc | sudo gpg --dearmor -o  /etc/apt/trusted.gpg.d/duo.gpg
apt-get update && apt-get install -y duo-unix

#edit /etc/duo/pam_duo.conf with ikey, secret key, and hostname
#prompt user for input and add config below...


echo "Enter the Duo integration key..."
read ikey
echo "Enter the Duo secret key..."
read skey
echo "Enter the Duo API hostname..."
read host

echo "[duo]" > /etc/duo/pam_duo.conf
echo "; Duo integration key" >> /etc/duo/pam_duo.conf
echo "ikey =" $ikey >> /etc/duo/pam_duo.conf
echo "; Duo secret key" >> /etc/duo/pam_duo.conf
echo "skey =" $skey >> /etc/duo/pam_duo.conf
echo "; Duo API host" >> /etc/duo/pam_duo.conf
echo "host =" $host >> /etc/duo/pam_duo.conf
echo "failmode = safe" >> /etc/duo/pam_duo.conf
echo "autopush = yes" >> /etc/duo/pam_duo.conf
echo "prompts = 1" >> /etc/duo/pam_duo.conf
echo "https_timeout=30" >> /etc/duo/pam_duo.conf

#make copy of sshd_config an replace with Duo config added
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
sudo cp duo-ubuntu/duo_sshd_config /etc/ssh/sshd_config

#make copy of PAM sshd and replace with Duo config added
sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.old
sudo cp duo-ubuntu/duo_pamd_sshd /etc/pam.d/sshd

#make copy of PAM system-auth and replace with Duo config added
sudo cp /etc/pam.d/common-auth /etc/pam.d/common-auth.old
sudo cp duo-ubuntu/duo_pamd_common-auth /etc/pam.d/common-auth

#SELinux may block PAM from contacting Duo, so adjust to allowing outgoing HTTP connections
#sudo make -C /opt/duo_unix_latest/pam_duo semodule
#sudo make -C /opt/duo_unix_latest/pam_duo semodule-install

#verify semodule includes Duo
#semodule -l | grep duo

 

#Now test and make sure auth is working.
