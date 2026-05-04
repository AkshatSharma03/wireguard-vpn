# Sharing Your WireGuard VPN with Others

## Overview
Each person who wants to use your VPN needs:
1. Their own private key (secret)
2. Their own public key (you'll need this)
3. A config file customized for them

## Step-by-Step Process

### For Your Clients (Each User):

1. **Generate their own keys:**
   ```bash
   wg genkey | tee my_private.key | wg pubkey > my_public.key
   cat my_private.key
   cat my_public.key
   ```

2. **Send you their PUBLIC key** (safe to share)
   - They keep their PRIVATE key secret!

3. **Wait for you to add them** to the server

4. **Receive config file from you**

5. **Import into WireGuard:**
   - Click "Import tunnel(s) from file"
   - Select the config you received
   - Toggle ON to connect

---

### For You (Server Admin):

1. **Client sends you their public key**

2. **Add them to server:**
   ```bash
   ssh root@YOUR_SERVER_IP
   wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.2/32
   wg-quick save wg0
   ```

3. **Get your server's public key:**
   ```bash
   cat /etc/wireguard/server_public.key
   ```

4. **Create config for client:**
   ```ini
   [Interface]
   Address = 10.0.0.2/24
   PrivateKey = THEIR_PRIVATE_KEY_HERE
   DNS = 1.1.1.1

   [Peer]
   PublicKey = YOUR_SERVER_PUBLIC_KEY
   Endpoint = YOUR_SERVER_IP:51820
   AllowedIPs = 0.0.0.0/0
   PersistentKeepalive = 25
   ```

5. **Share the config securely** (encrypted email, signal, etc)

---

## Security Notes

⚠️ **NEVER:**
- Share private keys via email/chat
- Reuse keys between clients
- Share your server's private key

✅ **DO:**
- Use unique keys for each client
- Share configs securely
- Disable inactive clients

---

## Multiple Clients Example

| Client | IP | Public Key | Status |
|--------|----|-----------:|--------|
| John-Laptop | 10.0.0.2 | abc123... | Active |
| Jane-Phone | 10.0.0.3 | def456... | Active |
| Bob-Work | 10.0.0.4 | ghi789... | Inactive |

---

## Commands Reference

**Add client:**
```bash
wg set wg0 peer PUBLIC_KEY allowed-ips 10.0.0.X/32
wg-quick save wg0
```

**List all clients:**
```bash
wg show
```

**Remove client:**
```bash
wg set wg0 peer PUBLIC_KEY remove
wg-quick save wg0
```

**Check client connection:**
```bash
wg show wg0 peers
```

---

## Troubleshooting for Clients

- Config file not found? Check the path
- Can't connect? Verify server IP and public key are correct
- Slow? Check your internet connection quality
- Disconnects? Adjust PersistentKeepalive to 10-15

