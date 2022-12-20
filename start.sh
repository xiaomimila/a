#!/bin/sh


proxy=$(ps -ef | grep -w prox[y] | wc -l)
if [[ $proxy = 0 ]]
then
  echo "启动..."

  vpn_ping=$(ping -c1 web-hosts)
  if [[ $vpn_ping =~ ms ]]
  then
    echo "网络正常"
    vpn_ip=$(ifconfig tailscale0 | grep "inet " | awk -F'[: ]+' '{ print $3 }')
    sleep 2s
    /usr/bin/proxy http -t tcp -p $vpn_ip:80,$vpn_ip:443 --dns-address "1.1.1.1:53" --dns-ttl 300 --daemon --forever
  else
    echo "网络异常退出"
    exit
  fi

else
  echo "已经启动"
fi


ipv6=$(/sbin/ip6tables -L)
if [[ $ipv6 =~ DROP ]]
then
  echo "IPv6 Yes"
else
	echo "SET IPv6"
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

