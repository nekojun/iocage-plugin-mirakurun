#!/bin/sh

cd /usr/local/Mirakurun
git pull
npm ci
npm run build
npm install . -g --production

service pm2_root start

echo "✅ Mirakurun update is complete!" > /root/PLUGIN_INFO
echo "Running as root user" >> /root/PLUGIN_INFO
echo "App dir: /usr/local/Mirakurun" >> /root/PLUGIN_INFO
echo "Config dir: /usr/local/etc/mirakurun" >> /root/PLUGIN_INFO
echo "Git hash: `git rev-parse --short HEAD`" >> /root/PLUGIN_INFO
echo "" >> /root/PLUGIN_INFO
echo "You can set the server, tuner, and channel from the Web UI." >> /root/PLUGIN_INFO
