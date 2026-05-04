#!/bin/bash

# WireGuard Server Setup Script
# Run this on your Linux server (Ubuntu/Debian)

set -e

echo "🔧 WireGuard Server Setup"
echo "========================"

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install WireGuard
echo "📥 Installing WireGuard..."
apt install wireguard wireguard-tools -y

# Generate server keys
echo "🔑 Generating server keys..."
mkdir -p /etc/wireguard
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key

echo "📋 Server Public Key:"
cat /etc/wireguard/server_public.key

# Get network interface
echo ""
echo "🌐 Available network interfaces:"
ip link show | grep "^[0-9]:" | awk '{print $2}' | sed 's/:$//'
echo ""
read -p "Enter your main network interface (e.g., eth0, ens3): " INTERFACE

# Create WireGuard config
PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)

cat > /etc/wireguard/wg0.conf << WGCONFIG
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $PRIVATE_KEY

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE
WGCONFIG

# Enable IP forwarding
echo "⚙️  Enabling IP forwarding..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Start WireGuard
echo "🚀 Starting WireGuard..."
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "✅ WireGuard server setup complete!"
echo ""
echo "📝 Server Public Key saved above - share with clients"
