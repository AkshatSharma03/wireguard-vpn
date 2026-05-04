#!/bin/bash

# Setup Multiple Devices on Same WireGuard Server
# Creates configs for multiple devices with unique keys

set -e

echo "📱 Multi-Device WireGuard Setup"
echo "=============================="
echo ""

read -p "Server IP (e.g., 168.119.125.218): " SERVER_IP
read -p "Server Public Key: " SERVER_PUB_KEY

echo ""
echo "Devices to create:"
read -p "Number of devices: " NUM_DEVICES

# Create output directory
OUTPUT_DIR="multi-device-configs-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "📝 Enter device names (one per line):"

# Store device names and create configs
declare -a DEVICES
for ((i=0; i<NUM_DEVICES; i++)); do
  read -p "Device $((i+1)) name (e.g., iphone, macbook): " DEVICE_NAME
  DEVICES+=("$DEVICE_NAME")
done

echo ""
echo "🔑 Generating keys and configs..."
echo ""

IP_COUNTER=2

for DEVICE in "${DEVICES[@]}"; do
  DEVICE_IP="10.0.0.$IP_COUNTER"
  
  # Generate keys
  wg genkey | tee "$OUTPUT_DIR/${DEVICE}_private.key" | wg pubkey > "$OUTPUT_DIR/${DEVICE}_public.key"
  
  # Create config
  cat > "$OUTPUT_DIR/${DEVICE}.conf" << CONF
[Interface]
Address = ${DEVICE_IP}/24
PrivateKey = $(cat "$OUTPUT_DIR/${DEVICE}_private.key")
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONF
  
  # Create README for this device
  cat > "$OUTPUT_DIR/${DEVICE}_README.txt" << README
Device: $DEVICE
IP Address: $DEVICE_IP
Created: $(date)

How to use:
1. Copy ${DEVICE}.conf to your device
2. Import into WireGuard app
   - Click "+"
   - Select "Create from file"
   - Choose ${DEVICE}.conf
3. Toggle ON to connect

Security:
- Keep ${DEVICE}_private.key SECRET
- Never share ${DEVICE}.conf file
- Only use on your $DEVICE

Files:
- ${DEVICE}.conf - Config file (import this)
- ${DEVICE}_private.key - Your private key (keep secret!)
- ${DEVICE}_public.key - Your public key (share with server admin)
README
  
  echo "✅ $DEVICE (IP: $DEVICE_IP)"
  ((IP_COUNTER++))
done

echo ""
echo "📊 Summary:"
echo "===================="
echo "Output directory: $OUTPUT_DIR"
echo "Devices created: $NUM_DEVICES"
echo ""

# Create server command file
cat > "$OUTPUT_DIR/SERVER_COMMANDS.sh" << SERVERCMD
#!/bin/bash
# Run these commands on your WireGuard server

echo "Adding peers to WireGuard..."

SERVERCMD

IP_COUNTER=2
for DEVICE in "${DEVICES[@]}"; do
  DEVICE_IP="10.0.0.$IP_COUNTER"
  echo "wg set wg0 peer \$(cat ${DEVICE}_public.key) allowed-ips ${DEVICE_IP}/32" >> "$OUTPUT_DIR/SERVER_COMMANDS.sh"
  ((IP_COUNTER++))
done

cat >> "$OUTPUT_DIR/SERVER_COMMANDS.sh" << SERVERCMD

echo "Saving configuration..."
wg-quick save wg0

echo "✅ All peers added!"
wg show
SERVERCMD

chmod +x "$OUTPUT_DIR/SERVER_COMMANDS.sh"

echo ""
echo "📋 Next Steps:"
echo "1. Copy public keys to server admin:"
for DEVICE in "${DEVICES[@]}"; do
  echo "   - ${DEVICE}_public.key"
done

echo ""
echo "2. Server admin runs:"
echo "   cat $OUTPUT_DIR/SERVER_COMMANDS.sh"
echo "   (or copy commands manually)"
echo ""
echo "3. Each device imports its config:"
for DEVICE in "${DEVICES[@]}"; do
  echo "   - $DEVICE: Import $OUTPUT_DIR/${DEVICE}.conf"
done

echo ""
echo "4. All devices can connect to server simultaneously!"
echo ""
echo "✨ Files ready in: $OUTPUT_DIR"
