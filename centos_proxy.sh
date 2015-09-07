
export PATH=$PATH:/usr/local/bin

if [ ! -f "/usr/bin/unzip" ]; then
yum install -y unzip
fi

if [ ! -f "/usr/bin/gcc" ]; then
yum install -y gcc-c++.x86_64
fi

if [ ! -f "/usr/lib64/libevent.so" ]; then
yum install -y libevent libevent-devel
fi

if [ ! -f "/usr/local/bin/redsocks" ]; then
# install redsocks
wget https://github.com/darkk/redsocks/archive/master.zip
unzip master.zip
cd redsocks-master/
make
cp redsocks.conf.example /etc/redsocks.conf
cp redsocks /usr/local/bin
cd ..
rm -rf master.zip redsocks-master

# config redsocks
sed -i 's/daemon = off/daemon = on/g' /etc/redsocks.conf
sed -i ':a;N;$!ba;s/example.org;\n\W\+port = 1080/192.168.2.171;\n        port = 10010/g' /etc/redsocks.conf

# start redsocks when system start
sed -i '$a/usr/local/bin/redsocks -c /etc/redsocks.conf' /etc/rc.d/rc.local

# config iptables
iptables -A OUTPUT -p tcp -d 172.19.0.0/16 -j REDIRECT --to-ports 12345 

# save iptables config
/sbin/service iptables save

# start redsocks
redsocks -c /etc/redsocks.conf
fi

