#!/bin/bash

# Exit on any error
set -e

echo "🚀 Installing dependencies..."
sudo apt update
sudo apt install -y nodejs npm ufw

echo "📦 Installing project dependencies..."
npm install

echo "🔐 Allowing port 3000 through firewall..."
sudo ufw allow 3000

echo "🛠 Installing PM2 globally..."
sudo npm install -g pm2

echo "🚀 Starting proxy server with PM2..."
pm2 start server.js --name google-api-proxy

echo "💾 Saving PM2 process list..."
pm2 save

echo "🔁 Enabling PM2 startup on boot..."
pm2 startup | tail -n 1 | bash

echo "✅ Proxy server is running and configured to start on boot!"

