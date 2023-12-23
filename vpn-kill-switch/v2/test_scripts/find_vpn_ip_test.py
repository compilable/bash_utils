import time
import select
import sys
import os


from subprocess import Popen, PIPE

from vpn_ip_match import check_for_vpn_ip

OPENVPN_PATH='/etc/openvpn'

def monitor_vpn_log():
    vpn_ip=None

    f = Popen(['tail','-F','/var/log/openvpn.log'],\
            stdout=PIPE,stderr=PIPE)
    p = select.poll()
    p.register(f.stdout)

    while True:
        if p.poll(1):
            text = f.stdout.readline()
            vpn_ip=check_for_vpn_ip(text)
            if vpn_ip:
                print "IP Found, configuring the firewall" + vpn_ip
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
    cmds = ["ufw allow out to " + ip +" port 1282", "ufw allow in to " + ip +" port 1282"]

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
    
    print 'starting the VPN using configuration  :', sys.argv[0]
    
    process = Popen(['openvpn' , '--config' , sys.argv[0]],stdout=PIPE, stdin=PIPE, stderr=PIPE,universal_newlines=True)
    print process.stdout.read()

start_vpn()
#reset_ufw()
#configure_ufw_defaults()
#monitor_vpn_log()