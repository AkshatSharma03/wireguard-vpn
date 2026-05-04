# WireGuard VPN Setup

This repo contains configuration files for setting up a WireGuard VPN server and client.

## ⚠️ SECURITY WARNING

**NEVER share your private keys!** Keep these files private:
- `client_private.key`
- `client.conf`
- Server private keys

## Setup Instructions

### Server Setup (Already Done)
```bash
apt update && apt upgrade -y
apt install wireguard -y
# ... (follow the WireGuard server setup steps)
```

### Client Setup

1. **Copy the example config:**
   ```bash
   cp client.conf.example client.conf
   ```

2. **Edit `client.conf` and add your keys:**
   - Replace `YOUR_CLIENT_PRIVATE_KEY_HERE` with your actual private key
   - Replace `YOUR_SERVER_PUBLIC_KEY_HERE` with the server's public key
   - Replace `YOUR_SERVER_IP` with your server's IP address

3. **Connect to VPN:**
   ```bash
   sudo wg-quick up ./client.conf
   ```

4. **Verify connection:**
   ```bash
   ping 10.0.0.1
   ```

5. **Disconnect (if needed):**
   ```bash
   sudo wg-quick down ./client.conf
   ```

## Security Notes

- Keep your `client_private.key` **secret**
- Never commit real config files to git
- Use `.gitignore` to prevent accidental commits
- Store backups in a **secure location**

## Files

- `client.conf.example` - Template for client configuration
- `.gitignore` - Prevents committing private keys
- `README.md` - This file

