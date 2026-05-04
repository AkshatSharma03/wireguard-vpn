# WireGuard Troubleshooting Guide

## Connection Issues

### Can't connect to VPN
- Check if WireGuard is running: `sudo wg show`
- Verify port 51820 is open: `sudo ufw allow 51820/udp`
- Check firewall: Hetzner Console → Firewalls → Add UDP 51820

### Ping not working (10.0.0.1)
- Ensure server is running: `ssh root@YOUR_IP "systemctl status wg-quick@wg0"`
- Check peer is added: `ssh root@YOUR_IP "wg show"`
- Verify routing: `netstat -rn | grep 10.0.0`

### Can't access external internet
- Enable IP forwarding on server
- Check iptables rules: `sudo iptables -t nat -L -n`
- Restart WireGuard: `sudo systemctl restart wg-quick@wg0`

## Disconnect/Reconnect

### Stop VPN
```bash
sudo wg-quick down ./client.conf
```

### Start VPN
```bash
sudo wg-quick up ./client.conf
```

### Check status
```bash
sudo wg show
```

## macOS Specific

### Import config into WireGuard app
1. Open WireGuard app
2. Click "Import tunnel(s) from file"
3. Select your `client.conf`
4. Toggle ON to connect

### Permission issues
```bash
sudo nano client.conf
# Make sure you have read permissions
```

## Linux Specific

### Install WireGuard
```bash
sudo apt install wireguard wireguard-tools
```

### Generate keys
```bash
wg genkey | tee private.key | wg pubkey > public.key
```

## Server Issues

### Restart WireGuard
```bash
ssh root@YOUR_IP "sudo systemctl restart wg-quick@wg0"
```

### Check logs
```bash
ssh root@YOUR_IP "sudo journalctl -u wg-quick@wg0 -f"
```

### Remove a peer
```bash
ssh root@YOUR_IP "wg set wg0 peer PEER_PUBLIC_KEY remove"
```
