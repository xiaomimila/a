#!/bin/sh


proxy=$(ps -ef | grep -w prox[y] | wc -l)
if [[ $proxy = 0 ]]
then
  echo "Start..."
  vpn_ip=$(vpn ip)
  sleep 2s
  /usr/bin/proxy http -t tcp -p $vpn_ip:80,$vpn_ip:443 --dns-address "1.1.1.1:53" --dns-ttl 300 --daemon --forever
else
  echo "already started"
fi


ipv6=$(/sbin/ip6tables -L)
if [[ $ipv6 =~ DROP ]]
then
  echo "Yes"
else
	echo "No"
   ipt6="/sbin/ip6tables"
   $ipt6 -F
   $ipt6 -X
   $ipt6 -Z
   $ipt6 -P INPUT DROP
   $ipt6 -P FORWARD DROP
   $ipt6 -P OUTPUT ACCEPT
   $ipt6 -A INPUT -i lo -j ACCEPT
   $ipt6 -A INPUT -p tcp --syn -j DROP
   $ipt6 -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
   $ipt6 -A INPUT -p ipv6-icmp -j ACCEPT
   $ipt6 -A INPUT -m state --state NEW -m udp -p udp -s fe80::/10 --dport 546 -j ACCEPT
   service ip6tables save && systemctl restart ip6tables
fi

