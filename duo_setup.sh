#!/bin/bash

#This script will download, install, and configure Duo MFA for Ubuntu Servers. Only tested on 24.04 LTS.
#Official instructions here https://duo.com/docs/duounix#install-pam_duo
#run all as sudo

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
echo "autopush = no" >> /etc/duo/pam_duo.conf
echo "prompts = 2" >> /etc/duo/pam_duo.conf
echo "https_timeout=60" >> /etc/duo/pam_duo.conf
echo "pushinfo=yes" >> /etc/duo/pam_duo.conf



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
