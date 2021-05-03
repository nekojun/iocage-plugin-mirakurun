#!/bin/sh

# Configure pcsc-lite
cat <<EOF >> /etc/devd.conf
attach 100 {
        device-name "ugen[0-9]+";
        action "/usr/local/sbin/pcscd -H";
};
detach 100 {
        device-name "ugen[0-9]+";
        action "/usr/local/sbin/pcscd -H";
};
EOF
sysrc -f /etc/rc.conf pcscd_enable="YES"

# Install libarib25
cd /usr/local
git clone https://github.com/stz2012/libarib25.git
cd ./libarib25
cmake .
gmake install clean

# Install recpt1
cd /usr/local
fetch https://hgotoh.jp/wiki/lib/exe/fetch.php/documents/freebsd/ptx/freebsd-019-recpt1_20190127.tar.gz
tar xf freebsd-019-recpt1_20190127.tar.gz
rm freebsd-019-recpt1_20190127.tar.gz
cd ./recpt1/recpt1
./autogen.sh
./configure --enable-b25
gmake
gmake install clean

# Install arib-b25-stream-test
cd /usr/local
fetch https://registry.npmjs.org/arib-b25-stream-test/-/arib-b25-stream-test-0.2.9.tgz
tar xf arib-b25-stream-test-0.2.9.tgz
rm arib-b25-stream-test-0.2.9.tgz
mv package arib-b25-stream-test
cd arib-b25-stream-test
mv package.json package.json.org
sed -e 's/"linux"/"linux","freebsd"/g' -e 's/make /make CC=cc CXX=c++ /g' package.json.org | jq . > package.json
npm install . -g --unsafe

# Install mirakurun
cd /usr/local
git clone -b feature/support-freebsd https://github.com/fuji44/Mirakurun.git
cd Mirakurun
npm install
npm run build
npm install . -g --production

# Configure mirakurun
echo "JAIL=YES" >> .env
mkdir /usr/local/etc/mirakurun
cp -v /usr/local/Mirakurun/config/server.yml /usr/local/etc/mirakurun/
cp -v /usr/local/Mirakurun/config/tuners.yml /usr/local/etc/mirakurun/
cp -v /usr/local/Mirakurun/config/channels.yml /usr/local/etc/mirakurun/

# Install pm2
npm install pm2 -g
cd /usr/local/Mirakurun
pm2 install pm2-logrotate

# Start service and registration to init system
pm2 start processes.json
pm2 save
pm2 startup

echo "Running as root user" >> /root/PLUGIN_INFO
echo "App dir: /usr/local/Mirakurun" >> /root/PLUGIN_INFO
echo "Config dir: /usr/local/etc/mirakurun" >> /root/PLUGIN_INFO
echo "" >> /root/PLUGIN_INFO
echo "You can set the server, tuner, and channel from the Web UI." >> /root/PLUGIN_INFO
