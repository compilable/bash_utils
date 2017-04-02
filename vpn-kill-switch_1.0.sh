#!/bin/bash

# 
# This file is part of the Bash-Tools distribution (https://github.com/compilable/Bash-Tools).
# Copyright (c) 2017 compilable.
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# Introduction:
# Purpose of this 
# Program execution : 

# vpn-kill-switch_1.0.sh [1] [2] [3]

# Program accepts 3 parameters
#   [1] : VPN configuration file (ending with ovpn), this will be pass with openvpn --config command.
#   [2] [3] : IP address followed by the port of a remote machine that will be allowed to access.

exec 1> >(logger -s -t $(basename $0)) 2>&1

# DEFAULT Parameters

openvpn_log=/var/log/openvpn.log
default_vpn_wait_time=10
default_bypass_port=22
default_openvpn_locaton=/etc/openvpn/

# check for ovpn file.

if [ -z "$1" ] 
then
    echo "No VPN configuratin file is provided, please provide the *.ovpn file."
    exit
fi

# kill existing openvpn connection & remove openvpn.log
echo "[1] kill existing openvpn connection & remove openvpn.log"

kill `pgrep openvpn`

rm $openvpn_log

# disable ufw
echo "[2] disable ufw firewall"
sudo ufw disable

# deny all outgoin traffic
echo "[3] deny all outgoin traffic"
sudo ufw default deny outgoing

# deny all incoming traffic
echo "[4] deny all incoming traffic"
sudo ufw default deny incoming

# allow connection over local network
echo "[5] allow connection over local network"
sudo ufw allow out to 192.168.1.0/24
sudo ufw allow in from 192.168.1.0/24


# try to establish the vpn connection
echo "[6] try to establish the vpn connection"
cd $default_openvpn_locaton

openvpn --config $1 &

# waiting for the connection to establish
(sleep $default_vpn_wait_time; echo "[7] waiting $default_vpn_wait_time ms. for the connection to establish..") 


# read log & find the vpn ip & port 
echo "[7] reading log file to find the vpn ip & port "

re="\[AF_INET\]([0-9.]+):([0-9]{4})"
ip_address=""
port=""

while IFS='' read -r line || [[ -n "$line" ]]; do

if [[ $line =~ $re ]]; then 
    ip_address=${BASH_REMATCH[1]} ;
    port=${BASH_REMATCH[2]} ;
else
    echo "Could not read the VPN IP address, re-trying"
fi

done < "$openvpn_log"


if [ -z $ip_address ] 
then
    echo "VPN IP address & port coudn't be found from the log, check for any connectivity issue."
    exit
else
    echo "[8] VPN URL = $ip_address:$port";
fi

# allow only vpn ip & ports
echo "[8] allowing traffic only via VPN & provided IP.."


if [ -z "$2" ] 
then
    echo "No IP address to by-pass is supplied, ignoring."
else
    echo "IP address to by-pass is supplied, $2"

    if [ -z "$3" ] 
    then
        echo "No port to by-pass is supplied, adding defaulg: 22"
    else
        default_bypass_port=$3
        fi

    echo "[9] allowing traffic via SSH,  $2 : $default_bypass_port "

    sudo ufw allow out to $2 port $default_bypass_port
fi

sudo ufw allow out to $ip_address port $port

sudo ufw allow out on tun0 from any to any

echo "[9] enabling ufw.. "

sudo ufw --force enable
