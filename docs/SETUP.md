# Setup Guide — clawpi-ai

Run OpenClaw on a Raspberry Pi as a 24/7 personal AI assistant, reachable via Telegram.

## Prerequisites

- Raspberry Pi 4B (4GB+ RAM)
- MicroSD card (32GB+) with Raspberry Pi OS Lite (64-bit)
- SSH access enabled
- Internet connection (ethernet or WiFi)
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com/))
- Telegram bot token (from [@BotFather](https://t.me/BotFather))

## Step 1 — Flash the Pi

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/):

1. Choose **Raspberry Pi OS Lite (64-bit)** — no desktop needed
2. Click the gear icon and configure:
   - Hostname: `clawpi`
   - Enable SSH with password authentication
   - Set username and password
   - Configure WiFi if needed
3. Flash and boot the Pi

## Step 2 — Install Tailscale

SSH into the Pi and install Tailscale for secure remote access:

```bash
ssh <user>@clawpi
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Follow the auth URL to add the Pi to your tailnet. Note the Tailscale IP (e.g. `100.x.x.x`).

## Step 3 — Clone and install

```bash
git clone https://github.com/BigDawg013/clawpi-ai.git ~/clawpi-ai
cd ~/clawpi-ai
chmod +x scripts/install.sh
./scripts/install.sh
```

This installs:
- Node.js 22 LTS (via NodeSource)
- OpenClaw CLI (via npm)
- pnpm (for skill/plugin management)

## Step 4 — Onboard OpenClaw

Run the onboarding wizard with your Anthropic API key:

```bash
openclaw onboard \
  --non-interactive \
  --accept-risk \
  --flow quickstart \
  --mode local \
  --auth-choice anthropic-api-key \
  --anthropic-api-key "sk-ant-YOUR-KEY-HERE" \
  --gateway-port 18789 \
  --gateway-bind tailnet \
  --gateway-auth token \
  --install-daemon \
  --skip-channels \
  --skip-skills \
  --skip-ui
```

This creates:
- Config at `~/.openclaw/openclaw.json`
- Agent workspace at `~/.openclaw/workspace`
- User systemd service `openclaw-gateway.service`
- Gateway bound to Tailscale IP on port 18789

Verify it's running:

```bash
openclaw gateway status
```

You should see `Runtime: running` and `RPC probe: ok`.

## Step 5 — Set up Telegram

### 5a. Create a Telegram bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot`
3. Choose a name (e.g. "ClawPi AI")
4. Choose a username (e.g. `clawpi_ai_bot`)
5. Copy the bot token (e.g. `1234567890:AAF...`)

### 5b. Enable the Telegram plugin

```bash
openclaw plugins enable telegram
systemctl --user restart openclaw-gateway
```

### 5c. Add the channel

```bash
openclaw channels add --channel telegram --token "YOUR_BOT_TOKEN"
```

Verify:

```bash
openclaw channels status
```

You should see: `Telegram default: enabled, configured, running`

### 5d. Pair your Telegram account

1. Open Telegram and send `/start` to your bot
2. The bot will reply with a pairing code (e.g. `YU299ZGW`)
3. Approve the pairing on the Pi:

```bash
openclaw pairing list --channel telegram
openclaw pairing approve <CODE> --channel telegram
```

Now send a message to your bot — it should reply!

## Step 6 — Verify everything

```bash
# Gateway health
openclaw health

# Channel status
openclaw channels status

# Gateway details
openclaw gateway status

# Live logs
openclaw logs
```

## Configuration reference

The config lives at `~/.openclaw/openclaw.json`. See `config/openclaw.json.example` in this repo for an annotated template.

Key settings:

| Setting | Value | Purpose |
|---------|-------|---------|
| `gateway.port` | `18789` | WebSocket gateway port |
| `gateway.bind` | `tailnet` | Bind to Tailscale IP (not localhost) |
| `gateway.auth.mode` | `token` | Token-based gateway auth |
| `channels.telegram.dmPolicy` | `pairing` | Require pairing code for DMs |
| `channels.telegram.groupPolicy` | `allowlist` | Only respond in approved groups |
| `agents.defaults.maxConcurrent` | `4` | Max concurrent agent sessions |

Change settings with:

```bash
openclaw config set gateway.bind tailnet
systemctl --user restart openclaw-gateway
```

## Updating

```bash
sudo npm i -g openclaw@latest
systemctl --user restart openclaw-gateway
openclaw --version
```

## Troubleshooting

```bash
# Check if gateway is running
openclaw gateway status

# Check for plugin issues
openclaw plugins doctor

# Full health check
openclaw doctor

# View recent logs
openclaw logs

# Restart gateway
systemctl --user restart openclaw-gateway

# Check systemd service
systemctl --user status openclaw-gateway
```

## Pairing with clawpi-scout

If you have a second Pi running [clawpi-scout](https://github.com/BigDawg013/clawpi-scout), point its `gateway.url` config at this Pi's Tailscale IP:

```yaml
# config/scout.yaml on the scout Pi
gateway:
  url: "http://<clawpi-tailscale-ip>:18789"
  health_interval: 60
  timeout: 10
  max_failures: 3
```

The scout will ping the gateway every 60 seconds and alert via Telegram + physical LEDs if it goes down.
