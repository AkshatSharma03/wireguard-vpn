# Multi-Device Setup Guide

## Overview

You can connect multiple devices to the same WireGuard server simultaneously:
- Phone, tablet, laptop, desktop all at once
- Each device gets unique private key & IP
- Easy to manage (add/remove devices)
- Better security & isolation

---

## Architecture

```
WireGuard Server (168.119.125.218:51820)
│
├─ Device 1: iPhone (10.0.0.2)
├─ Device 2: MacBook (10.0.0.3)
├─ Device 3: iPad (10.0.0.4)
└─ Device 4: Work PC (10.0.0.5)

All devices can be connected simultaneously!
```

---

## Quick Start

### Method 1: Using Helper Script (Easiest)

```bash
cd ~/Documents/wireguard-vpn
./scripts/setup-multiple-devices.sh
```

This will:
1. Ask for device names
2. Generate unique keys for each
3. Create configs for each device
4. Generate server commands

### Method 2: Manual Setup

#### Step 1: Create First Device

```bash
# Generate keys for iPhone
wg genkey | tee iphone_private.key | wg pubkey > iphone_public.key

# Create config
cat > iphone.conf << 'CONFIG'
[Interface]
Address = 10.0.0.2/24
PrivateKey = YOUR_IPHONE_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = YOUR_SERVER_PUBLIC_KEY
Endpoint = 168.119.125.218:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONFIG
```

#### Step 2: Create Second Device

```bash
# Generate keys for MacBook
wg genkey | tee macbook_private.key | wg pubkey > macbook_public.key

# Create config
cat > macbook.conf << 'CONFIG'
[Interface]
Address = 10.0.0.3/24
PrivateKey = YOUR_MACBOOK_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = YOUR_SERVER_PUBLIC_KEY
Endpoint = 168.119.125.218:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
CONFIG
```

#### Step 3: Add to Server

```bash
# SSH to server
ssh root@168.119.125.218

# Add iPhone
wg set wg0 peer IPHONE_PUBLIC_KEY allowed-ips 10.0.0.2/32

# Add MacBook
wg set wg0 peer MACBOOK_PUBLIC_KEY allowed-ips 10.0.0.3/32

# Save
wg-quick save wg0

# Verify
wg show
```

---

## Important: Unique IPs

⚠️ **Each device MUST have a unique IP in the VPN:**

| Device | IP |
|--------|---|
| iPhone | 10.0.0.2 |
| MacBook | 10.0.0.3 |
| iPad | 10.0.0.4 |
| Work PC | 10.0.0.5 |

If you use the same IP for two devices, the second one will disconnect the first!

---

## Device Connection Limits

### How many devices can connect?

**Theoretically:** Unlimited (subnet is 10.0.0.0/24 = 254 IPs)

**Practically:** 
- Single server: 50-100+ devices
- Performance depends on server specs
- Our Hetzner 4GB handles 10-20+ easily

### Bandwidth sharing:

- All devices share server bandwidth
- Each gets fair share
- Total speed = server speed ÷ connected devices

---

## Managing Devices

### View Connected Devices

```bash
ssh root@168.119.125.218 "wg show"

# Output shows:
# peer: <public_key>
#  allowed ips: <ip>
#  latest handshake: <time>
#  transfer: <data>
```

### Disconnect One Device

```bash
ssh root@168.119.125.218 "wg set wg0 peer PUBLIC_KEY remove && wg-quick save wg0"
```

### Disable Then Re-enable

```bash
# Temporary disable (don't delete)
ssh root@168.119.125.218 "wg set wg0 peer PUBLIC_KEY allowed-ips 0.0.0.0"

# Re-enable
ssh root@168.119.125.218 "wg set wg0 peer PUBLIC_KEY allowed-ips 10.0.0.X/32"
```

---

## Device Types & Setup

### iOS
1. Download WireGuard from App Store
2. Receive `.conf` file via email/message
3. Open file → Import → Activate

### Android
1. Download WireGuard from Play Store
2. Receive `.conf` file via email/message
3. Open file → Import → Activate

### macOS
1. Download WireGuard from App Store
2. Receive `.conf` file
3. Open file → Import → Activate
4. Or use command line: `sudo wg-quick up ./config.conf`

### Linux
```bash
# Install
sudo apt install wireguard

# Connect
sudo wg-quick up ./config.conf

# Disconnect
sudo wg-quick down ./config.conf
```

### Windows
1. Download WireGuard installer
2. Receive `.conf` file
3. Import into app → Activate

---

## Security Considerations

### ✅ Best Practices

- Use **unique keys** for each device
- Use **unique IPs** for each device
- Generate keys **on each device** (not server)
- Keep `.conf` files **private**
- Use secure channels to **share configs**

### ❌ Don't Do This

- Share same `.conf` between devices
- Reuse private keys
- Post configs publicly
- Email configs unencrypted

### 🔒 Sharing Configs Securely

- Signal/Telegram (encrypted messaging)
- ProtonMail (encrypted email)
- Age/GPG encryption
- In-person (USB drive)

---

## Troubleshooting

### One device connects, others don't
- Check each has **unique IP**
- Verify **server has all peers added**
- Check **firewall allows UDP 51820**

### All devices disconnect simultaneously
- Server crashed: `systemctl status wg-quick@wg0`
- Network issue on server
- Check server logs: `journalctl -u wg-quick@wg0 -f`

### Some devices very slow
- Check bandwidth usage: `vnstat` or `nethogs`
- Other devices using too much
- Server internet speed

### Can't reach other devices
- Device-to-device traffic is allowed by default
- Test: `ping 10.0.0.2` from another device
- Check firewall in wg0 config

---

## Bandwidth Allocation

Example with 4 devices:

```
Server bandwidth: 1000 Mbps
Connected devices: 4

Average per device: 250 Mbps
(Fair share if all download equally)

If one device is idle:
Remaining 3 devices: ~333 Mbps each
```

---

## Example: Home Setup

```
You have:
- iPhone (personal)
- MacBook (work & personal)
- iPad (family)
- Family laptop (shared)

All can connect simultaneously:
✅ You on iPhone at work
✅ Partner on MacBook at home
✅ Kid on iPad watching
✅ Guest on family laptop

All encrypted through your VPN!
```

---

## Common Questions

### Q: Will devices slow each other down?
**A:** Slightly if all use bandwidth. With good internet, hardly noticeable.

### Q: Can I connect same device twice?
**A:** Not recommended. Use unique IP per device.

### Q: Can I share config with family?
**A:** Yes, but each person should get unique IP. Use `setup-multiple-devices.sh`

### Q: What if I lose a device?
**A:** Remove peer: `wg set wg0 peer PUBLIC_KEY remove`

### Q: Maximum devices?
**A:** 254 (subnet /24). Performance degrades after ~50-100.

