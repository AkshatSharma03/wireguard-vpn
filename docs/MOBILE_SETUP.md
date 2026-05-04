# WireGuard Mobile Setup Guide

## iOS & Android Setup

### Step 1: Install WireGuard App
- **iOS:** App Store → Search "WireGuard" → Install
- **Android:** Google Play → Search "WireGuard" → Install

### Step 2: Get Your Config

You have two options:

**Option A: QR Code (Recommended)**
- Server admin generates QR code
- Open WireGuard app → Tap **"+"**
- Tap **"Create from QR code"**
- Scan the QR code
- ✅ Done!

**Option B: Config File**
- Receive config file via email/message
- Open WireGuard app → Tap **"+"**
- Tap **"Create from file"**
- Select the config file
- ✅ Done!

### Step 3: Connect
- Tap the tunnel name
- Toggle switch ON
- You're now on the VPN! 🛡️

---

## Generating QR Code for Clients

**On server:**
```bash
apt install qrencode
qrencode -t ansiutf8 < client.conf
```

**Or create PNG:**
```bash
qrencode -o client_qr.png < client.conf
```

Then share the QR code image with them!

---

## What You'll See When Connected

✅ Green indicator next to tunnel name
✅ Your IP changes to VPN server's IP
✅ "VPN" appears in status bar (iOS)
✅ All traffic goes through VPN

---

## Disconnect
- Open WireGuard app
- Toggle switch OFF
- Back to normal internet

---

## Troubleshooting

### Config file won't import
- Make sure client has their private key in the file
- Check file format is `.conf`
- Verify file isn't corrupted

### Can't scan QR code
- Lighting - try better lighting
- Steady hand - keep camera still
- QR might be too small - increase size in terminal

### Connected but no internet
- Check server is running: `systemctl status wg-quick@wg0`
- Verify peer is added: `wg show`
- Restart WireGuard on phone

### Kills other apps' internet
- This is normal - WireGuard routes all traffic through VPN
- Disable "Kill Switch" in app settings if needed

---

## Best Practices

✅ Keep app updated
✅ Disable when not needed (saves battery)
✅ Use strong wifi/data signals
✅ Don't share config files (contains private key!)

---

## Security Notes

⚠️ Your private key is in the config file
- Don't screenshot the QR code
- Don't share the config file
- Keep your phone locked

---

## Testing Connection

After connecting, test with:

**What's my IP?**
Visit: https://ipinfo.io

Should show:
- IP: Your VPN server's IP
- Location: Server's location

---

## Multiple Devices

You can use the same config on multiple devices, BUT:
- Each device needs unique keys (recommended)
- Easier to manage if you give each device its own config
- Use `manage-clients.sh` to create unique configs

