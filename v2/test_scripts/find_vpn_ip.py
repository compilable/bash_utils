import time
import subprocess
import select

from vpn_ip_match import check_for_vpn_ip

f = subprocess.Popen(['tail','-F','/var/log/openvpn.log'],\
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
p = select.poll()
p.register(f.stdout)

while True:
    if p.poll(1):
        text = f.stdout.readline()
        vpn_ip=check_for_vpn_ip(text)
        if vpn_ip:
            break
    time.sleep(1)
