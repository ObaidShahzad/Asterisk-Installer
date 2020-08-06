#!/bin/bash

# Author: Obaid Shahzad
# Build Date: 23 jul 2020
# Version: 1.0.0
# 
# Title: Asterisk
# 	A simple script to install Asterisk on Linux
#
# Tested on: Ubuntu 18.04

if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31m Please run as root \033[0m"
  exit
fi

apt update && apt -y upgrade
apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion  libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev
cd /usr/src/
curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
tar xvf asterisk-16-current.tar.gz
cd asterisk-16*/
contrib/scripts/get_mp3_source.sh
sed -i 's/'libvpb-dev'/''/g' contrib/scripts/install_prereq
contrib/scripts/install_prereq install  # Configuring libvpb1 - 61
./configure
make menuselect.makeopts
menuselect/menuselect --enable chan_ooh323 --enable format_mp3 --enable CORE-SOUNDS-EN-WAV --enable CORE-SOUNDS-EN-ULAW --enable CORE-SOUNDS-EN-ALAW --enable CORE-SOUNDS-EN-GSM --enable CORE-SOUNDS-EN-G729 --enable CORE-SOUNDS-EN-G722 --enable CORE-SOUNDS-EN-SLN16 --enable CORE-SOUNDS-EN-SIREN7 --enable CORE-SOUNDS-EN-SIREN14 --enable MOH-OPSOUND-WAV --enable MOH-OPSOUND-ULAW --enable MOH-OPSOUND-ALAW --enable MOH-OPSOUND-GSM --enable EXTRA-SOUNDS-EN-WAV --enable EXTRA-SOUNDS-EN-ULAW --enable EXTRA-SOUNDS-EN-ALAW --enable EXTRA-SOUNDS-EN-GSM --enable app_macro
make
make install
make samples
make config
ldconfig
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib/asterisk
sed -i 's/'#AST_USER'/'AST_USER'/g' /etc/default/asterisk
sed -i 's/'#AST_GROUP'/'AST_GROUP'/g' /etc/default/asterisk
sed -i 's/;runuser/runuser/g' /etc/asterisk/asterisk.conf
sed -i 's/;rungroup/rungroup/g' /etc/asterisk/asterisk.conf
systemctl restart asterisk
systemctl enable asterisk
ufw allow proto tcp from any to any port 5060,5061
echo -e '\033[0;32m

---- INSTALLATION SUCCESSFUL ----

\033[0m
'
asterisk -rvv
