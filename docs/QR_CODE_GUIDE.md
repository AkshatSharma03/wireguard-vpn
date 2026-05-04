# QR Code Generation & Sharing Guide

## Why QR Codes?

QR codes make sharing WireGuard configs with mobile users super simple:
- No manual typing of keys
- No copy-paste errors
- Just scan and connect!

---

## Quick Start

### For Server Admin:

1. **Create config for client:**
   ```bash
   # Add their public key to server
   wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.2/32
   wg-quick save wg0
   ```

2. **Generate QR code:**
   ```bash
   qrencode -t ansiutf8 < client.conf
   ```

3. **Share the QR code image:**
   ```bash
   qrencode -o client_qr.png < client.conf
   ```

4. **Send to client** via email, Slack, Signal, etc.

---

## For Clients: Scanning QR Code

### iOS
1. Open **WireGuard** app
2. Tap **"+"** button (bottom right)
3. Tap **"Create from QR code"**
4. Scan the QR code
5. Review and confirm
6. Toggle **ON** to connect

### Android
1. Open **WireGuard** app
2. Tap **"+"** button (bottom right)
3. Tap **"Scan from QR code"**
4. Point camera at QR code
5. Review and confirm
6. Toggle **ON** to connect

---

## Using the Helper Script

We provide `generate-qr.sh` to make this easier:

```bash
# Generate QR in terminal
./scripts/generate-qr.sh ~/path/to/client.conf

# Outputs:
# - Terminal ASCII art QR code
# - PNG file (client_qr.png)
```

### Example:
```bash
cd ~/Documents/wireguard-vpn
./scripts/generate-qr.sh /tmp/john-laptop.conf
```

This creates:
- Terminal display (for copying/printing)
- `john-laptop_qr.png` (to email/share)

---

## Step-by-Step Server Workflow

### For Each New Client:

```bash
# 1. Client generates their keys and sends public key

# 2. Add them to your server (SSH into server)
ssh root@YOUR_SERVER_IP

# 3. Add peer with unique IP
wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.2/32
wg-quick save wg0

# 4. Create their config file (on your computer)
cat > john-config.conf << 'CONF'
[Interface]
Address = 10.0.0.2/24
PrivateKey = JOHN_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = YOUR_SERVER_PUBLIC_KEY
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONF

# 5. Generate QR code
qrencode -o john-qr.png < john-config.conf

# 6. Send john-qr.png to John
```

---

## Sharing QR Code Securely

⚠️ **Important:** The QR code contains John's private key!

**Do:**
- ✅ Send via encrypted channels (Signal, ProtonMail)
- ✅ Delete after client confirms they scanned it
- ✅ Send only to the intended person

**Don't:**
- ❌ Post publicly on social media
- ❌ Share unencrypted via email (unless internal)
- ❌ Screenshot and send (screenshot might be backed up)
- ❌ Use plain text messaging apps

---

## Batch Generation (Multiple Clients)

```bash
#!/bin/bash
# Script to generate QR codes for multiple clients

CLIENTS=("john-laptop" "jane-phone" "bob-work")
SERVER_IP="168.119.125.218"
SERVER_PUB_KEY="zwaxTj9BDl5fR/hw7Sh7VApkQ6Rve4UNNI6JTVIdXQE="

for i in "${!CLIENTS[@]}"; do
  CLIENT="${CLIENTS[$i]}"
  IP=$((i + 2))  # 10.0.0.2, 10.0.0.3, etc.
  
  # Create config
  cat > "${CLIENT}.conf" << CONF
[Interface]
Address = 10.0.0.${IP}/24
PrivateKey = PASTE_PRIVATE_KEY_HERE
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONF
  
  # Generate QR
  qrencode -o "${CLIENT}_qr.png" < "${CLIENT}.conf"
  echo "✅ Created ${CLIENT}_qr.png"
done
```

---

## Troubleshooting

### QR code won't scan
- Better lighting
- Larger screen or printed version
- Try different camera angle
- Make sure it's in focus

### Client can't import
- Verify config file format is valid
- Check private key is correct
- Ensure DNS line doesn't have typos

### Need reinstall?
- Delete tunnel in app
- Scan QR code again
- Regenerate QR code if lost

---

## Mobile Testing

**Best way to test QR codes:**

1. Generate QR code with `generate-qr.sh`
2. Save PNG to computer
3. Send to phone via email/Slack
4. Open image on phone
5. Open WireGuard app
6. Tap "+" → "Create from QR code"
7. Point at image on another device
8. Test connection

---

## Distribution Methods

| Method | Security | Ease | Best For |
|--------|----------|------|----------|
| QR Code Print | ⭐⭐⭐ | Easy | In-person |
| Encrypted Email | ⭐⭐⭐ | Medium | Trusted contacts |
| Signal/Telegram | ⭐⭐⭐ | Easy | Tech-savvy users |
| File upload (SFTP) | ⭐⭐⭐ | Hard | Secure setup |

---

## Advanced: Generate with Private Key

For automated client onboarding:

```bash
#!/bin/bash
# Generate complete config with both keys

CLIENT_NAME=$1
CLIENT_IP=$2
SERVER_IP="168.119.125.218"
SERVER_PUB="zwaxTj9BDl5fR/hw7Sh7VApkQ6Rve4UNNI6JTVIdXQE="

# Generate client keys
wg genkey | tee ${CLIENT_NAME}_private.key | wg pubkey > ${CLIENT_NAME}_public.key

# Create config with private key
cat > "${CLIENT_NAME}.conf" << CONF
[Interface]
Address = ${CLIENT_IP}/24
PrivateKey = $(cat ${CLIENT_NAME}_private.key)
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONF

# Generate QR
qrencode -o "${CLIENT_NAME}_qr.png" < "${CLIENT_NAME}.conf"

echo "✅ Created:"
echo "  Config: ${CLIENT_NAME}.conf"
echo "  QR: ${CLIENT_NAME}_qr.png"
echo "  Public Key: $(cat ${CLIENT_NAME}_public.key)"
```

