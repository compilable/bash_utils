
import re

search_string = "Sat Dec 28 06:58:08 2019 [vpnsecure-server] Peer Connection Initiated with [AF_INET]139.99.131.191:1282"
VPN_IP_REGEX = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,4}\Z"



def check_for_vpn_ip(vpn_log_text):
   match = re.search(VPN_IP_REGEX, vpn_log_text)
   
   if match:
      print('VPN IP found',match.group(0))
   else:
      print('VPN IP not found')

check_for_vpn_ip(search_string)