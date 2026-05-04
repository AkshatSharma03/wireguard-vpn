#!/bin/bash

# Batch QR Code Generator for WireGuard
# Generates QR codes for multiple clients at once

set -e

echo "📦 Batch WireGuard QR Generator"
echo "=============================="
echo ""

# Create output directory
OUTPUT_DIR="qr-codes-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "📁 Output directory: $OUTPUT_DIR"
echo ""

# Check dependencies
if ! command -v qrencode &> /dev/null; then
  echo "❌ qrencode not installed"
  echo "Install with: brew install qrencode (macOS) or apt install qrencode (Linux)"
  exit 1
fi

# Interactive menu
echo "How would you like to generate QR codes?"
echo "1. From existing config files"
echo "2. Create new clients with keys"
echo ""
read -p "Choose (1-2): " CHOICE

case $CHOICE in
  1)
    echo ""
    echo "Place all .conf files in current directory"
    echo "Then drag config files or enter paths"
    echo ""
    
    count=0
    while true; do
      read -p "Config file path (or 'done'): " CONFIG
      
      if [ "$CONFIG" = "done" ]; then
        break
      fi
      
      if [ ! -f "$CONFIG" ]; then
        echo "⚠️  File not found: $CONFIG"
        continue
      fi
      
      # Generate QR
      BASENAME=$(basename "$CONFIG" .conf)
      OUTPUT="$OUTPUT_DIR/${BASENAME}_qr.png"
      qrencode -o "$OUTPUT" < "$CONFIG"
      
      echo "✅ Generated: $OUTPUT"
      ((count++))
    done
    
    echo ""
    echo "📊 Summary: Generated $count QR codes"
    ;;
    
  2)
    echo ""
    read -p "Server IP (e.g., 168.119.125.218): " SERVER_IP
    read -p "Server Public Key: " SERVER_PUB_KEY
    read -p "Number of clients: " NUM_CLIENTS
    
    for ((i=1; i<=NUM_CLIENTS; i++)); do
      CLIENT_IP=$((i+1))
      CLIENT_NAME=$(printf "client-%02d" $i)
      
      # Generate keys
      wg genkey | tee "$OUTPUT_DIR/${CLIENT_NAME}_private.key" | wg pubkey > "$OUTPUT_DIR/${CLIENT_NAME}_public.key"
      
      # Create config
      cat > "$OUTPUT_DIR/${CLIENT_NAME}.conf" << CONF
[Interface]
Address = 10.0.0.${CLIENT_IP}/24
PrivateKey = $(cat "$OUTPUT_DIR/${CLIENT_NAME}_private.key")
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONF
      
      # Generate QR
      qrencode -o "$OUTPUT_DIR/${CLIENT_NAME}_qr.png" < "$OUTPUT_DIR/${CLIENT_NAME}.conf"
      
      echo "✅ Created: $CLIENT_NAME"
    done
    
    echo ""
    echo "📋 Files generated:"
    echo "  • Config files (.conf)"
    echo "  • QR codes (.png)"
    echo "  • Public keys (.pub)"
    ;;
    
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "📁 All files in: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Review files in $OUTPUT_DIR"
echo "2. Send public keys to server admin (if applicable)"
echo "3. Share QR codes with clients (encrypted)"
echo "4. Clients scan QR and connect"
