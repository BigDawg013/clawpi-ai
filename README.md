# clawpi-ai

Run [OpenClaw](https://openclaw.ai/) on a Raspberry Pi as a 24/7 personal AI assistant — reachable via Telegram, WhatsApp, Discord, and more.

## Hardware

- Raspberry Pi 4B (4GB+ RAM)
- MicroSD card (32GB+)
- Ethernet or WiFi
- [Tailscale](https://tailscale.com/) for secure remote access

## What's here

```
scripts/
  install.sh                  ← Full setup: Node.js + OpenClaw + pnpm
config/
  openclaw.json.example       ← Annotated config template (no secrets)
docs/
  SETUP.md                    ← Step-by-step guide from flash to first message
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

# 4. Onboard with your Anthropic API key
openclaw onboard \
  --non-interactive \
  --accept-risk \
  --flow quickstart \
  --mode local \
  --auth-choice anthropic-api-key \
  --anthropic-api-key "sk-ant-YOUR-KEY" \
  --gateway-port 18789 \
  --gateway-bind tailnet \
  --gateway-auth token \
  --install-daemon \
  --skip-channels \
  --skip-skills \
  --skip-ui

# 5. Enable Telegram
openclaw plugins enable telegram
systemctl --user restart openclaw-gateway
openclaw channels add --channel telegram --token "YOUR_BOT_TOKEN"

# 6. Pair your Telegram account
#    Send /start to your bot on Telegram
#    Then approve the pairing:
openclaw pairing list --channel telegram
openclaw pairing approve <CODE> --channel telegram
```

## Architecture

This Pi serves as an always-on AI bot on the local network (via Tailscale). It pairs with [clawpi-scout](https://github.com/BigDawg013/clawpi-scout) which monitors its health from a separate Pi with a physical LED dashboard.

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Mac Mini        │     │  Raspberry Pi    │     │  Raspberry Pi   │
│  ClawBot #1      │     │  clawpi-ai       │     │  clawpi-scout   │
│  (primary)       │     │  ClawBot #2      │◄────│  monitors both  │
└────────┬────────┘     │  (always-on)     │     │  LED dashboard  │
         │               └────────┬─────────┘     └────────┬────────┘
         │                        │                         │
         └──────── Tailscale mesh network ──────────────────┘
```

## Key commands

```bash
# Check gateway status
openclaw gateway status

# Check channel health
openclaw channels status

# View logs
openclaw logs

# Restart gateway
systemctl --user restart openclaw-gateway

# Update OpenClaw
sudo npm i -g openclaw@latest
systemctl --user restart openclaw-gateway
```

## Related repos

- [clawpi-scout](https://github.com/BigDawg013/clawpi-scout) — GPIO health monitor with LEDs, LCD, buzzer, bar graph, 7-segment, dot matrix
- [openclaw-setup](https://github.com/BigDawg013/openclaw-setup) — OpenClaw configuration on the Mac Mini

## License

MIT
