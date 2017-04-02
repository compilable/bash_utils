# Bash-Tools
Customized scripts written to automate common tasks under Unix environment.

# License
The programs found under this repo are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.

You should have received a copy of the GNU General Public License under [gpl-2.0.txt](https://github.com/compilable/Bash-Tools/blob/master/gpl-2.0.txt) . For more information, see <http://www.gnu.org/licenses/>.

# Projects

### VPN Kill Switch (openvpn / ufw)
This script will run as a daemon service and restrict all your incoming and outgoing traffic only via a configured VPN connection. In case of a communication failure (VPN connection brekdown) all the connections will be restricted.
