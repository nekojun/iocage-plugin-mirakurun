#!/bin/sh

cd /usr/local/Mirakurun || { echo "Mirakurun app dir not found."; exit 1; }
git pull
npm ci
npm run build
npm install . -g --production

service pm2_root start
{
        echo "✅ Mirakurun update is complete!"
        echo "Running as root user"
        echo "App dir: /usr/local/Mirakurun"
        echo "Config dir: /usr/local/etc/mirakurun"
        echo "Git hash: $(git rev-parse --short HEAD)"
        echo ""
        echo "You can set the server, tuner, and channel from the Web UI."
} > /root/PLUGIN_INFO
