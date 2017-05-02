#!/bin/bash -e

set -e

export PATH=$PATH:/usr/local/bin

has() {
  type "$1" > /dev/null 2>&1
  return $?
}

if ! has "gcc"; then
yum install -y gcc-c++.x86_64
fi

if [ ! -f "/usr/lib64/libevent-2.0.so.5" ]; then
yum install -y libevent2 libevent2-devel
fi

if ! has "git"; then
# install git
yum install -y git
fi

if ! has "redsocks"; then
# install redsocks
git clone https://github.com/darkk/redsocks.git
cd redsocks/
make
cp redsocks.conf.example /etc/redsocks.conf
cp redsocks /usr/local/bin
cd ..
rm -rf redsocks

# config redsocks
sed -i 's/daemon = off/daemon = on/g' /etc/redsocks.conf
sed -i ':a;N;$!ba;s/example.org;\n\W\+port = 1080/192.168.2.171;\n        port = 10010/g' /etc/redsocks.conf

# start redsocks when system start
sed -i '$a/usr/local/bin/redsocks -c /etc/redsocks.conf' /etc/rc.d/rc.local

# config iptables
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -t nat -A OUTPUT -p tcp -d 172.19.0.0/16 -j REDIRECT --to-ports 12345 

# save iptables config
/sbin/service iptables save
chkconfig --level 53 iptables on

# start redsocks
redsocks -c /etc/redsocks.conf
fi

