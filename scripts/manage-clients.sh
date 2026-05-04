#!/bin/bash

# WireGuard Client Management Script
# Run on server to add/remove clients

set -e

echo "🔧 WireGuard Client Manager"
echo "============================"
echo ""
echo "Usage:"
echo "  1. Add client     - Generate config for new client"
echo "  2. List peers     - Show all connected clients"
echo "  3. Remove peer    - Disconnect a client"
echo ""

read -p "Choose option (1-3): " OPTION

case $OPTION in
  1)
    read -p "Enter client name (e.g., john-laptop): " CLIENT_NAME
    read -p "Enter client IP (e.g., 10.0.0.2): " CLIENT_IP
    read -p "Enter client public key: " CLIENT_PUB_KEY
    
    # Add peer to server
    echo "Adding peer to WireGuard..."
    wg set wg0 peer "$CLIENT_PUB_KEY" allowed-ips "$CLIENT_IP/32"
    wg-quick save wg0
    
    # Create config file
    SERVER_PUB=$(wg show wg0 public-key)
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    cat > "/tmp/${CLIENT_NAME}.conf" << CONFIG
[Interface]
Address = $CLIENT_IP/24
PrivateKey = CLIENT_PRIVATE_KEY_HERE
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONFIG
    
    echo "✅ Peer added!"
    echo "📋 Share this config with client: /tmp/${CLIENT_NAME}.conf"
    echo "   (They must add their private key to: CLIENT_PRIVATE_KEY_HERE)"
    ;;
    
  2)
    echo ""
    echo "Connected Peers:"
    wg show wg0 peers
    ;;
    
  3)
    echo ""
    read -p "Enter public key to remove: " REMOVE_KEY
    wg set wg0 peer "$REMOVE_KEY" remove
    wg-quick save wg0
    echo "✅ Peer removed!"
    ;;
    
  *)
    echo "Invalid option"
    ;;
esac
