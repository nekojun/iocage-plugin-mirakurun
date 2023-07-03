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
git clone https://github.com/stz2012/libarib25.git /usr/local/libarib25
cd /usr/local/libarib25 || { echo "Clone libarib25 failed."; exit 1; }
cmake .
gmake install clean

# Install recpt1
fetch -o /tmp/recpt1.tar.gz https://hgotoh.jp/wiki/lib/exe/fetch.php/documents/freebsd/ptx/freebsd-019-recpt1_20190127.tar.gz
tar -xf /tmp/recpt1.tar.gz -C /usr/local
cd /usr/local/recpt1/recpt1 || { echo "Extracting recpt1 failed."; exit 1; }
./autogen.sh
./configure --enable-b25
gmake
gmake install clean

# Install arib-b25-stream-test
fetch -o /tmp/arib-b25-stream-test.tgz https://registry.npmjs.org/arib-b25-stream-test/-/arib-b25-stream-test-0.2.9.tgz
tar -xf /tmp/arib-b25-stream-test.tgz -C /tmp
mv /tmp/package /usr/local/arib-b25-stream-test
cd /usr/local/arib-b25-stream-test || { echo "Extracting arib-b25-stream-test failed."; exit 1; }
mv package.json package.json.org
sed -e 's/"linux"/"linux","freebsd"/g' -e 's/make /make CC=cc CXX=c++ /g' package.json.org | jq . > package.json
npm install . -g --unsafe

# Install mirakurun
git clone -b task/support_freebsd https://github.com/nekojun/Mirakurun.git /usr/local/Mirakurun
cd /usr/local/Mirakurun || { echo "Clone Mirakurun failed."; exit 1; }
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
pm2 install pm2-logrotate

# Start service and registration to init system
pm2 start processes.json
pm2 save
pm2 startup

{
        echo "✅ Mirakurun install is complete!"
        echo "Running as root user"
        echo "App dir: /usr/local/Mirakurun"
        echo "Config dir: /usr/local/etc/mirakurun"
        echo "Git hash: $(git rev-parse --short HEAD)"
        echo ""
        echo "You can set the server, tuner, and channel from the Web UI."
} > /root/PLUGIN_INFO
