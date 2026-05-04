#!/bin/bash

# WireGuard QR Code Generator
# Generates QR codes from config files for easy mobile sharing

set -e

usage() {
  echo "📱 WireGuard QR Code Generator"
  echo ""
  echo "Usage:"
  echo "  $0 <config-file>              Generate QR from config"
  echo "  $0 -o <output> <config-file>  Save to PNG file"
  echo "  $0 -h                         Show help"
  echo ""
  echo "Examples:"
  echo "  $0 client.conf"
  echo "  $0 -o john-qr.png client.conf"
  exit 1
}

# Check if qrencode is installed
check_qrencode() {
  if ! command -v qrencode &> /dev/null; then
    echo "❌ qrencode not installed"
    echo ""
    echo "Install with:"
    echo "  macOS: brew install qrencode"
    echo "  Linux: apt install qrencode"
    echo "  Other: https://fukuchi.org/works/qrencode/"
    exit 1
  fi
}

# Parse arguments
OUTPUT_FILE=""
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -o)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      CONFIG_FILE="$1"
      shift
      ;;
  esac
done

# Validate input
if [ -z "$CONFIG_FILE" ]; then
  echo "❌ Config file not provided"
  usage
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ File not found: $CONFIG_FILE"
  exit 1
fi

# Check dependencies
check_qrencode

echo "📱 Generating QR Code"
echo "=================="
echo "Config: $CONFIG_FILE"
echo ""

# Display QR code in terminal
echo "📲 Scan this QR code with WireGuard app:"
echo ""
qrencode -t ansiutf8 < "$CONFIG_FILE"
echo ""

# Generate PNG if output file specified
if [ -n "$OUTPUT_FILE" ]; then
  qrencode -o "$OUTPUT_FILE" < "$CONFIG_FILE"
  echo "✅ QR code saved: $OUTPUT_FILE"
  
  # Get file size
  SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
  echo "📊 File size: $SIZE"
  echo ""
  echo "📧 You can now:"
  echo "  • Email the image to the client"
  echo "  • Share via Signal/Telegram"
  echo "  • Print for in-person distribution"
  echo "  • Upload to secure share service"
else
  # Suggest saving
  SUGGESTED_OUTPUT="${CONFIG_FILE%.conf}_qr.png"
  echo "💡 Tip: Save as PNG file:"
  echo "  $0 -o $SUGGESTED_OUTPUT $CONFIG_FILE"
fi

echo ""
echo "✨ Steps for client:"
echo "  1. Download WireGuard app"
echo "  2. Tap '+' button"
echo "  3. Tap 'Create from QR code'"
echo "  4. Scan this code"
echo "  5. Toggle ON to connect"
