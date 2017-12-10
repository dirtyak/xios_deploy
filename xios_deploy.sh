#!/bin/bash
#
#

# Verify swapfile
grep swapfile /etc/fstab
if [ $? == 0 ]
then
        echo "swap exists, skipping..."
else
        # Create 2GB swap file
        fallocate -l 2G /swapfile
        # Confirm creation of 2GB file
        ls -ls /swapfile
        # Set Permissions on swap file
        chmod 600 /swapfile
        # Enable swap file
        mkswap 600 /swapfile
        swapon /swapfile
        # Make Changes Permanent
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        # Confirm Changes
        free -h
fi

# Install Dependencies
apt-get -y update && apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libcrypto++-dev libqrencode-dev libminiupnpc-dev libgmp-dev libgmp3-dev$

# Clone Repo
cd
git clone https://github.com/davembg/xios

# Create executable
cd xios/src
make -f makefile.unix

# Create XIOS configuration file
mkdir $home/.XIOS1

# Populate missing information in XIOS.conf file
echo "rpcuser=<ANY user>" > $home/.XIOS1/.XIOS.conf
echo "rpcpassword=<ANY password>" >> $home/.XIOS1/.XIOS.conf
echo "rpcallowip=123.0.0.1" >> $home/.XIOS1/.XIOS.conf
echo "rpcport=9101" >> $home/.XIOS1/.XIOS.conf
echo "listen=1" >> $home/.XIOS1/.XIOS.conf
echo "server=1" >> $home/.XIOS1/.XIOS.conf
echo "daemon=1" >> $home/.XIOS1/.XIOS.conf
echo "staking=0" >> $home/.XIOS1/.XIOS.conf
echo "longtimestamps=1" >> $home/.XIOS1/.XIOS.conf
echo "port=9001"  >> $home/.XIOS1/.XIOS.conf

# Start XIOSd Application
/root/xios/src/XIOSd -datadir=/root/.XIOS1 -config=/root/.XIOS1/XIOS.conf -daemon
