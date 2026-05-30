# xrdeploy

Interactive Xray VLESS+Reality deployment helper.

`xrdeploy` supports three deployment roles:

```text
1. Standalone proxy
   Client -> Xray -> Internet

2. Relay node
   Client -> Xray Relay -> Xray Exit -> Internet

3. Exit node
   Client/Relay -> Xray Exit -> Internet
```

The tool asks which role you want, generates UUID / Reality keys / shortId, writes `/usr/local/etc/xray/config.json`, validates the config, and can restart Xray.

> This project is intended for servers you own or administer. Follow local law and your hosting provider's terms.

---

## Recommended server preparation

Before installing Xray or xrdeploy, create a separate sudo user and harden SSH.

### 1. Update the system

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Create a non-root user

Replace `deploy` with your preferred username.

```bash
adduser deploy
usermod -aG sudo deploy
```

### 3. Add your SSH public key

Log in as root or another sudo user and copy your public key:

```bash
mkdir -p /home/deploy/.ssh
nano /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

Test login from a new terminal before disabling root/password login:

```bash
ssh deploy@YOUR_SERVER_IP
```

### 4. Harden SSH

Edit SSH server config:

```bash
sudo nano /etc/ssh/sshd_config
```

Recommended settings:

```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

Keep your existing SSH session open until you confirm a new key-based login works.

---

## Installation

### Option A: one-line installer

After logging in as your non-root sudo user:

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/xrdeploy/main/install.sh | sudo bash
```

or:

```bash
wget -qO- https://raw.githubusercontent.com/USERNAME/xrdeploy/main/install.sh | sudo bash
```

Replace `USERNAME` with your GitHub username after publishing the repository.

### Option B: manual install

```bash
sudo apt update
sudo apt install -y curl ca-certificates openssl python3
curl -fsSL https://raw.githubusercontent.com/USERNAME/xrdeploy/main/xrdeploy -o xrdeploy
chmod +x xrdeploy
sudo mv xrdeploy /usr/local/bin/xrdeploy
sudo xrdeploy
```

---

## Usage

Run:

```bash
sudo xrdeploy
```

Menu:

```text
1) Deploy standalone proxy      Client -> Xray -> Internet
2) Deploy relay node            Client -> Relay -> Exit -> Internet
3) Deploy exit node             Client/Relay -> Exit -> Internet
4) Show Xray config
5) Show xrdeploy state
6) Validate config
7) Restart Xray
0) Exit
```

---

## Deployment modes

### 1. Standalone proxy

Use this when the server is the only proxy node.

```text
Client -> this Xray -> Internet
```

The generated config contains:

- VLESS+Reality inbound
- `direct` outbound
- `block` outbound
- routing from inbound to `direct`

The tool prints a VLESS client link.

### 2. Relay node

Use this on the first server in a chain.

```text
Client -> this Relay -> Exit Xray -> Internet
```

You need parameters from the exit node:

- exit IP/domain
- exit port
- exit UUID
- exit Reality SNI
- exit Reality public key
- exit shortId

The relay creates its own VLESS+Reality inbound for clients, then forwards all tunnel traffic to the configured exit outbound.

### 3. Exit node

Use this on the last server in a chain.

```text
Client/Relay -> this Exit -> Internet
```

The generated config contains a VLESS+Reality inbound and direct Internet outbound. The tool prints a VLESS link/parameters that can be used by a relay node.

---

## Firewall

Open the inbound port you selected, for example:

```bash
sudo ufw allow 443/tcp
```

or for a custom port:

```bash
sudo ufw allow 4433/tcp
```

---

## Files

`xrdeploy` writes:

```text
/usr/local/etc/xray/config.json
/etc/xrdeploy/state.json
```

Before overwriting the Xray config, it creates:

```text
/usr/local/etc/xray/config.json.bak
```

---

## Security notes

- Do not publish private keys, UUIDs, or full client links.
- The Reality public key is used by clients; the private key stays on the server.
- For a relay chain, the relay has two separate Reality contexts:
  - inbound private key for clients connecting to the relay;
  - outbound public key of the exit node.
- Prefer SSH keys and disable root login before deployment.

---

## Development

Clone and run locally:

```bash
git clone https://github.com/USERNAME/xrdeploy.git
cd xrdeploy
sudo ./xrdeploy
```

Publish:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:USERNAME/xrdeploy.git
git push -u origin main
```
