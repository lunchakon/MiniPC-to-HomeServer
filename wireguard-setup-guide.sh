# Server Setup (Ubuntu/Debian)

# Install WireGuard
apt update
apt install wireguard

# Generate server private and public keys
cd /etc/wireguard
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Create server configuration
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = $(cat server_private.key)
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1
[Peer]
PublicKey = <Client1PublicKey>
AllowedIPs = 10.0.0.2/32

# Client 2 (add more as needed)
[Peer]
PublicKey = <Client2PublicKey>
AllowedIPs = 10.0.0.3/32
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Start WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Client Setup (Linux)

# Install WireGuard
apt install wireguard

# Generate client keys
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Create client configuration
cat > wg0.conf << EOF
[Interface]
PrivateKey = $(cat client_private.key)
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <ServerPublicKey>
Endpoint = server.domain.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Start WireGuard connection
wg-quick up wg0

# Basic WireGuard commands

# Check connection status
wg show

# Bring interface up/down
wg-quick up wg0
wg-quick down wg0

# Add a peer dynamically
wg set wg0 peer <PublicKey> allowed-ips 10.0.0.3/32 endpoint example.com:51820
