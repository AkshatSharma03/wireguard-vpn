#!/bin/bash

# Generate QR code for WireGuard mobile setup

if [ -z "$1" ]; then
  echo "Usage: $0 <config-file>"
  echo "Example: $0 client.conf"
  exit 1
fi

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ File not found: $CONFIG_FILE"
  exit 1
fi

echo "📱 Generating QR Code for: $CONFIG_FILE"
echo ""

# Check if qrencode is installed
if ! command -v qrencode &> /dev/null; then
  echo "⚠️  qrencode not installed"
  echo "Install with: apt install qrencode"
  exit 1
fi

# Generate QR code in terminal
qrencode -t ansiutf8 < "$CONFIG_FILE"

echo ""
echo "✅ Scan the QR code above with WireGuard mobile app!"
echo ""
echo "📱 Steps:"
echo "1. Open WireGuard app"
echo "2. Tap '+' button"
echo "3. Tap 'Create from QR code'"
echo "4. Scan the code above"
echo "5. Toggle ON to connect"

# Also create PNG version if possible
if command -v qrencode &> /dev/null; then
  OUTPUT="${CONFIG_FILE%.conf}_qr.png"
  qrencode -o "$OUTPUT" < "$CONFIG_FILE"
  echo ""
  echo "📸 Also saved as: $OUTPUT"
fi
