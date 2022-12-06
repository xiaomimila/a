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

