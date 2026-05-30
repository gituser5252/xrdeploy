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

### Option A: reviewed installer, recommended

After logging in as your non-root sudo user, download and inspect the installer first:

```bash
curl -fsSL https://raw.githubusercontent.com/gituser5252/xrdeploy/main/install.sh -o install.sh
less install.sh
sudo bash install.sh
```

Replace `gituser5252` with your GitHub username after publishing the repository.

### Option B: one-line installer, convenient but riskier

Only use this if you trust the repository content you are piping into `sudo bash`:

```bash
curl -fsSL https://raw.githubusercontent.com/gituser5252/xrdeploy/main/install.sh | sudo bash
```

The installer also uses the official upstream XTLS installer for Xray Core. Review that upstream script too if you need a stricter security posture.

### Option B: manual install

```bash
sudo apt update
sudo apt install -y curl ca-certificates openssl python3
curl -fsSL https://raw.githubusercontent.com/gituser5252/xrdeploy/main/xrdeploy -o xrdeploy
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
4) Show Xray config, redacted
5) Show xrdeploy state, redacted
6) Validate config
7) Restart Xray
8) Check camouflage domain
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


## Camouflage domain checker

`xrdeploy` includes an optional helper for checking whether a domain is a reasonable Reality camouflage target. It checks DNS, ping, TLS 1.2/1.3, X25519, HTTP/2, HTTP/3 hints, redirects and likely CDN usage.

Run from the menu:

```text
8) Check camouflage domain
```

Or directly after installation:

```bash
/usr/local/lib/xrdeploy/reality_check.sh --no-install --no-external example.com:443
```

Privacy note: the checker performs network requests to the domain being tested. By default the menu disables the extra `ipinfo.io` lookup; direct CLI users can pass `--no-external` to disable it too.

The checker can install missing diagnostic tools unless `--no-install` is used. Review the script before running it on sensitive systems.

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

Before overwriting the Xray config, it creates timestamped backups:

```text
/usr/local/etc/xray/config.json.bak.YYYYMMDD-HHMMSS
```

If generated config validation fails, xrdeploy restores the latest backup automatically.

---

## Security notes

- Do not publish private keys, UUIDs, shortIds, or full client links.
- Menu options that show config/state redact sensitive values by default.
- The Reality public key is used by clients; the private key stays on the server.
- For a relay chain, the relay has two separate Reality contexts:
  - inbound private key for clients connecting to the relay;
  - outbound public key of the exit node.
- Prefer SSH keys and disable root login before deployment.

---

## Development

Clone and run locally:

```bash
git clone https://github.com/gituser5252/xrdeploy.git
cd xrdeploy
sudo ./xrdeploy
```

Publish:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:gituser5252/xrdeploy.git
git push -u origin main
```
