# clawpi-ai

Run [OpenClaw](https://openclaw.ai/) on a Raspberry Pi as a 24/7 personal AI assistant — reachable via Telegram, WhatsApp, Discord, and more.

## Hardware

- Raspberry Pi 4B (4GB+)
- MicroSD card (32GB+)
- Ethernet or WiFi
- Tailscale for secure remote access

## What's here

```
scripts/
  install.sh       ← Full setup script: Node.js, OpenClaw, systemd service
  openclaw.env      ← Environment variables (gitignored, template provided)
docs/
  SETUP.md          ← Step-by-step setup guide
```

## Quick start

```bash
# 1. Flash Raspberry Pi OS Lite (64-bit) with SSH enabled
# 2. SSH in and clone this repo
git clone https://github.com/BigDawg013/clawpi-ai.git
cd clawpi-ai

# 3. Run the install script
chmod +x scripts/install.sh
./scripts/install.sh

# 4. Run onboarding
openclaw onboard

# 5. Enable the systemd service
sudo systemctl enable --now clawpi-ai
```

## Architecture

This Pi serves as an always-on AI bot on the local network (via Tailscale). It pairs with [clawpi-scout](https://github.com/BigDawg013/clawpi-scout) which monitors its health from a separate Pi.

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Mac Mini        │     │  Pi 4B (4GB+)    │     │  Pi 4B (4GB)    │
│  ClawBot #1      │◄───►│  clawpi-ai       │     │  clawpi-scout   │
│  (primary)       │     │  ClawBot #2      │◄────│  monitors both  │
└─────────────────┘     │  (always-on)      │     │  LED dashboard  │
                         └──────────────────┘     └─────────────────┘
         ▲                        ▲                        │
         └────────── Tailscale mesh network ───────────────┘
```

## License

MIT
