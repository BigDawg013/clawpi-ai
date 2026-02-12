# Setup Guide — clawpi-ai

Run OpenClaw on a Raspberry Pi as a 24/7 personal AI assistant.

## Prerequisites

- Raspberry Pi 4B (4GB+ RAM recommended)
- MicroSD card (32GB+) with Raspberry Pi OS Lite (64-bit)
- SSH access enabled
- Internet connection (ethernet or WiFi)

## Step 1 — Flash the Pi

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/):

1. Choose **Raspberry Pi OS Lite (64-bit)** — no desktop needed
2. Click the gear icon and configure:
   - Hostname: `clawpi`
   - Enable SSH with password auth
   - Set username and password
   - Configure WiFi if needed
3. Flash and boot the Pi

## Step 2 — Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Follow the auth URL to add the Pi to your tailnet.

## Step 3 — Clone and install

```bash
git clone https://github.com/BigDawg013/clawpi-ai.git
cd clawpi-ai
chmod +x scripts/install.sh
./scripts/install.sh
```

This installs Node.js 22, OpenClaw, and creates the systemd service.

## Step 4 — Configure environment

```bash
cp scripts/openclaw.env.example scripts/openclaw.env
nano scripts/openclaw.env
```

Add your Anthropic API key (required) and any chat platform tokens.

## Step 5 — Run onboarding

```bash
openclaw onboard
```

This walks you through connecting your chat platforms (Telegram, WhatsApp, Discord, etc.).

## Step 6 — Enable the service

```bash
sudo systemctl enable --now clawpi-ai
```

## Verify

```bash
# Check service status
sudo systemctl status clawpi-ai

# Watch logs
journalctl -u clawpi-ai -f

# Check Tailscale connectivity
tailscale status
```

## Updating OpenClaw

```bash
sudo npm i -g openclaw@latest
sudo systemctl restart clawpi-ai
```

## Pairing with clawpi-scout

If you have a second Pi running [clawpi-scout](https://github.com/BigDawg013/clawpi-scout), point its `gateway.url` config at this Pi's Tailscale IP:

```yaml
gateway:
  url: "https://clawpi.<your-tailnet>.ts.net"
```

The scout will monitor this Pi's OpenClaw gateway and alert you via Telegram + physical LEDs if it goes down.
