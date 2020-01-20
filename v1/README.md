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

# Starting the script:
* Modify the OVPN file configuration: Below configuration needs to be added to the ovpn file to facilitate automated connections. <https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html>

>           ns-cert-type server
>           nobind
>           script-security 2
>           askpass {PATH TO PASSWORD FILE}
>           log-append {VPN LOG FILE LOCATION}
>           up /etc/openvpn/update-resolv-conf.sh
>           down /etc/openvpn/update-resolv-conf.sh

*Below is a sample value set:*
>           ns-cert-type server
>           nobind
>           script-security 2
>           askpass /etc/openvpn/vpn_pass.txt
>           log-append /var/log/openvpn.log
>           up /etc/openvpn/update-resolv-conf.sh
>           down /etc/openvpn/update-resolv-conf.sh

* Run the below command to star : 

> vpn-kill-switch_X.X.sh [1] [2] [3]

 *Program accepts 3 parameters
>           [1] : VPN configuration file (ending with ovpn), this will be pass with openvpn --config command.
>           [2] [3] : IP address followed by the port of a remote machine that will be allowed to access.

# Note:
* You need the sudo privileges to run this script.
>           sudo chmod 777 vpn-kill-switch_X.X.sh
