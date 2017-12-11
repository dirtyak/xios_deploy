#!/bin/bash
#
# XIOS_deploy is a script designed to install several XIOSd a way more simple
#
# Usage : ./xios_deploy [n] 
# Example : './xios_deploy 3' will deploy 3 XIOSd folder with files as .XIOS1 .XIOS2 and .XIOS3
#
#
function usage {
if [ -z $1 ]; then
        echo "Usage: ./xios_deploy.sh [howmany]"
        exit 0
else
        echo "This will install XIOSd in each differents folder"
fi
}

function verifyswap {
        grep swap /etc/fstab
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
}

function satisfydependencies {
apt-get -y update && apt-get -y install build-essential libssl-dev libdb++-dev libboost-all-dev libcrypto++-dev libqrencode-dev libminiupnpc-dev libgmp-dev libgmp3-dev$
}

function installXIOSd {
# Verify if XIOSd is installed, if not install it
        XIOSd_path="$HOME/xios/src/XIOSd"
        if [ -f $XIOSd_path ]; then
                echo "XIOSd is already installed."
        else
                echo "Let's Make XIOSd."
                # Clone Repo
                cd
                git clone https://github.com/davembg/xios
                # Create executable
                cd $HOME/xios/src
                make -f makefile.unix
        fi
}

function makeconfigfiles {
        i="1"
        port=$[9000-1]
        count=$1
        staking=0
        while [ $i -lt $[$count+1] ]
                do
                # Populate several XIOS.conf files
                mkdir $HOME/.XIOS$i
                touch $HOME/.XIOS$i/.XIOS.conf
                echo "rpcuser=<ANY user>" > $HOME/.XIOS$i/.XIOS.conf
                echo "rpcpassword=<ANY password>" >> $HOME/.XIOS$i/.XIOS.conf
                echo "rpcallowip=127.0.0.1" >> $HOME/.XIOS$i/.XIOS.conf
                echo "rpcport=9100" >> $HOME/.XIOS$i/.XIOS.conf
                echo "listen=1" >> $HOME/.XIOS$i/.XIOS.conf
                echo "server=1" >> $HOME/.XIOS$i/.XIOS.conf
                echo "daemon=1" >> $HOME/.XIOS$i/.XIOS.conf
                echo "staking=0" >> $HOME/.XIOS$i/.XIOS.conf
                echo "longtimestamps=1" >> $HOME/.XIOS$i/.XIOS.conf
                echo "port=$[$port+$i]"  >> $HOME/.XIOS$i/.XIOS.conf
                # Start XIOSd deamon(s)
                /root/xios/src/XIOSd -datadir=/root/.XIOS$i -config=/root/.XIOS$i/XIOS.conf -daemon
        i=$[$i+1]
        done
}
