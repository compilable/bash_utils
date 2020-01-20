# VPN Kill Switch ( Linux : openvpn / ufw)
This script will run as a daemon service and restrict all your incoming and outgoing traffic only via a configured VPN connection. In case of a communication failure (VPN connection brekdown) all the connections will be restricted.

> An Internet kill switch is the cybercrime and countermeasures concept of activating a single shut off mechanism for all   Internet traffic. The theory behind a kill switch is creation of a single point of control for one authority or another to  control in order to shut down the Internet to protect it from unspecified assailants; (Wikipedia).

# License
The programs found under this repo are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.

You should have received a copy of the GNU General Public License under [gpl-2.0.txt](https://github.com/compilable/Bash-Tools/blob/master/gpl-2.0.txt) . For more information, see http://www.gnu.org/licenses/.

# Prerequisites:
You need to have installed below programs to run this script:
* ufw firewall (https://help.ubuntu.com/community/UFW)
* openvpn (https://openvpn.net/)
* python (https://www.python.org/downloads/)

# Starting the script:
* Download your VPN server list from the VPN service provider and extract it to a location with R/W access. (eg. /etc/openvpn/)
* Modify the OVPN file configuration: Below configuration needs to be added to the ovpn file to facilitate automated connections. <https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html>

>           ns-cert-type server
>           nobind
>           script-security 2
>           askpass {PATH TO PASSWORD FILE}
>           log-append {VPN LOG FILE LOCATION}
>           up /etc/openvpn/update-resolv-conf.sh
>           down /etc/openvpn/update-resolv-conf.sh

* Below is a sample value set:*
>           ns-cert-type server
>           nobind
>           script-security 2
>           askpass /etc/openvpn/vpn_pass.txt
>           log-append /var/log/openvpn.log
>           up /etc/openvpn/update-resolv-conf.sh
>           down /etc/openvpn/update-resolv-conf.sh

* Copy the Script file to the openvpn server location. (eg. /etc/openvpn/)
* Run the below command to star : 

> python vpn-kill-switch_X.X.py [1]

 *Program accepts 1 parameter
>           [1] : VPN configuration file (ending with ovpn), this will be pass with openvpn --config command.

# Note:
* You need the sudo privileges to run this script.
>           sudo chmod 777 vpn-kill-switch_X.X.py

* In case the VPN is dropped it won't be possible to reconnect automatically.
* Need to disable the ufw manually before starting again.

# IMPORTANT:
* Use a service like dnsleak.net to verify your IP address is not leaking.
* In case your DNS is leaking change the default DNS server and verify DNS is not leaking.
* Disable / Kill all the network processes when enabling the ufw.
> 		sudo ufw disable

# REFERENCE
Setting up opnevpn
https://askubuntu.com/questions/460871/how-to-setup-openvpn-client

Conncting to VPN using ovpn file
https://naveensnayak.com/2013/03/04/ubuntu-openvpn-with-ovpn-file/

Download openvpn
https://openvpn.net/community-downloads/

UFW firewall commands
https://www.configserverfirewall.com/ufw-ubuntu-firewall/ufw-delete-rule/

Create a VPN kill switch with UFW – Protect yourself with a VPN kill switch
https://www.smarthomebeginner.com/vpn-kill-switch-with-ufw/

Installing OpenVPN
https://help.ubuntu.com/lts/serverguide/openvpn.html

**Copyright &copy; 2020 compilable.**
> This program is free software: you can redistribute it and/or modify  it under the terms of the GNU General Public License as published by  the Free Software Foundation, version 3.
