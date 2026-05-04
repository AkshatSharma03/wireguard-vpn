#!/bin/bash

# WireGuard Client Setup Script
# Run this on your client machine to generate keys and config

set -e

echo "🔧 WireGuard Client Setup"
echo "========================"

# Generate client keys
echo "🔑 Generating client keys..."
wg genkey | tee client_private.key | wg pubkey > client_public.key

echo ""
echo "📋 Client Public Key (share with server admin):"
cat client_public.key

echo ""
echo "🔐 Client Private Key (KEEP SECRET!):"
cat client_private.key

echo ""
read -p "Enter server public key: " SERVER_PUB_KEY
read -p "Enter server IP address (e.g., 168.119.125.218): " SERVER_IP
read -p "Enter client IP address (e.g., 10.0.0.2): " CLIENT_IP

# Create client config
cat > client.conf << CLIENTCONFIG
[Interface]
Address = $CLIENT_IP/24
PrivateKey = $(cat client_private.key)
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CLIENTCONFIG

echo ""
echo "✅ Client config created: client.conf"
echo "📥 Import it into WireGuard app or connect with:"
echo "   sudo wg-quick up ./client.conf"
