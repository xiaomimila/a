#!/bin/sh


echo "本脚本由 AaIT.io 专业住宅IP提供商制作"
echo "真实住宅拉宽带获取的纯净当地住宅IP记得来买 ！！"
sleep 10s


# 安装 WGET
if ! command -v wget &> /dev/null; then
  echo "wget is not installed. Installing..."
  if command -v yum &> /dev/null; then
    yum install -y wget
  else
    echo "Unable to install wget. Please install it manually."
    exit 1
  fi
fi


# 安装 GOST
if [ ! -f "/usr/local/bin/gost" ]; then
  cd /root/
  wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
  gzip -d gost-linux-amd64-2.11.5.gz
  mv gost-linux-amd64-2.11.5 gost
  mv gost /usr/local/bin/
  chmod 755 /usr/local/bin/gost
  cp /root/socks5.sh /usr/local/bin/
  echo "请输入Socks5用户名："
  read user
  echo "请输入Socks5密码："
  read pass
  echo "请输入Socks5端口："
  read port
  new_command="    nohup /usr/local/bin/gost -L $user:$pass@:$port socks5://:$port >/dev/null 2>&1 &"
  sed -i "/nohup/c\\${new_command//&/\\&}" /usr/local/bin/socks5.sh
  echo >> /etc/crontab
  echo "*/1 * * * * root /usr/local/bin/socks5.sh" >> /etc/crontab
  echo "Socks5 连接信息如下，如果是NAT机型记得把虚拟机内部端口替换为公网IP的转发端口"
  ip=$(curl -sS https://api.ipify.org)
  echo -e
  echo -e
  echo "socks5://$ip:$port:$user:$pass"
  echo -e
  echo -e
  rm -rf /root/socks5.sh
  exit
else
  gost=$(pgrep -x gost)
  if [ -z "$gost" ]; then
    nohup
  else
    echo "gost Running ..."
  fi
fi


# 定时重启
target_time="04:00"
current_time=$(date +"%H:%M")
if [[ $current_time == $target_time ]]; then
  sleep 50s
  pkill -9 gost
else
  echo "Current time is $current_time. Waiting for $target_time to execute the command."
fi

