'''
# 
# This file is part of the Bash-Tools distribution (https://github.com/compilable/Bash-Tools).
# Copyright (c) 2020 compilable.
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

# Introduction: This script will run as a deamon service and restrict all your incoming and # # # # outgoing traffice only via a configured VPN connection. In case of a communication failure (VPN # connection brekdown) all the connections will be restricted.

# Please read : vpn-kill-switch_2.0 -Readme.txt for more informaiton.

'''

import time
import select
import sys
import os
from subprocess import Popen, PIPE
import re

VPN_IP_REGEX = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,4}"

OPENVPN_PATH='/etc/openvpn'

def monitor_vpn_log():
    vpn_ip=None

    log_monitor = Popen(['tail','-F','/var/log/openvpn.log'],\
            stdout=PIPE,stderr=PIPE)
    p = select.poll()
    p.register(log_monitor.stdout)

    keep_reading=True

    while log_monitor.returncode is None:
        if p.poll(1):
            text = log_monitor.stdout.readline()
            vpn_ip=check_for_vpn_ip(text)
            if vpn_ip:
                print "IP Found, configuring the firewall" + vpn_ip
                keep_reading=False
                log_monitor.kill()

                break
        time.sleep(1)    

    if vpn_ip:
        vpn_is_connectd(vpn_ip)
    else:
        print "vpn is not connected"

def vpn_is_connectd(vpn_ip):
    #reset_ufw()
    #configure_ufw_defaults()
    vpn_info=vpn_ip.split(":")
    add_vpn_ip_to_ufw(vpn_info[0],vpn_info[1])
    configure_firewall()
    
def configure_firewall():
    reset_ufw()
    configure_ufw_defaults()
    enable_ufw()
    
def reset_ufw():
    proc = Popen(['ufw', 'reset'],stdout=PIPE, stdin=PIPE, stderr=PIPE,universal_newlines=True)
    stdout,err = proc.communicate(input="{}\n".format("Y"))
    print stdout

def configure_ufw_defaults():
    cmds = ['ufw allow in to 192.168.1.0/24', 'ufw allow out to 192.168.1.0/24','ufw default deny outgoing',
    'ufw default deny incoming','ufw allow out on tun0 from any to any']

    encoding = 'utf8'
    process = Popen('/bin/bash', stdin=PIPE, stdout=PIPE, stderr=PIPE)

    for cmd in cmds:
        process.stdin.write(cmd + "\n")
    process.stdin.close()
    print process.stdout.read()

def add_vpn_ip_to_ufw(ip,port):
    cmds = ["ufw allow out to " + ip +" port "+ str(port), "ufw allow in to " + ip +" port "+ str(port)]

    encoding = 'utf8'
    process = Popen('/bin/bash', stdin=PIPE, stdout=PIPE, stderr=PIPE)

    for cmd in cmds:
        print cmd
        process.stdin.write(cmd + "\n")
    process.stdin.close()
    print process.stdout.read()

def enable_ufw():
    process = Popen(['ufw', 'enable'],stdout=PIPE, stdin=PIPE, stderr=PIPE,universal_newlines=True)
    print process.stdout.read()

def start_vpn():
    if len(sys.argv) == 1:
        sys.exit("VPN confguration file is not provided.")

    # add temp rule to make the connection
    add_vpn_ip_to_ufw('any',110)
    
    print 'starting the VPN using configuration  :', sys.argv[1]
    
    process = Popen(['openvpn' , '--config' , sys.argv[1]],stdout=PIPE, stdin=PIPE, stderr=PIPE,universal_newlines=True)
    process.stdin.close()

def check_for_vpn_ip(vpn_log_text):
   match = re.search(VPN_IP_REGEX, vpn_log_text)
   # print(vpn_log_text)

   if "Peer Connection Initiated with" in vpn_log_text:
      if match:
         print('VPN IP found, applying the killswitch.',match.group(0))
         return match.group(0)
   else:
      print("")


start_vpn()
monitor_vpn_log()
