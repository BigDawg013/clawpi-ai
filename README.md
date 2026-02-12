<p align="center">
  <img src="https://img.shields.io/badge/platform-Raspberry%20Pi-c51a4a?style=flat-square&logo=raspberrypi&logoColor=white" alt="Raspberry Pi" />
  <img src="https://img.shields.io/badge/runtime-Node.js%2022-339933?style=flat-square&logo=nodedotjs&logoColor=white" alt="Node.js 22" />
  <img src="https://img.shields.io/badge/AI-OpenClaw-ff6600?style=flat-square" alt="OpenClaw" />
  <img src="https://img.shields.io/badge/network-Tailscale-0052ff?style=flat-square&logo=tailscale&logoColor=white" alt="Tailscale" />
  <img src="https://img.shields.io/badge/channel-Telegram-26a5e4?style=flat-square&logo=telegram&logoColor=white" alt="Telegram" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License" />
</p>

# clawpi-ai

Run [OpenClaw](https://openclaw.ai/) on a Raspberry Pi as a **24/7 personal AI assistant** — reachable from anywhere via Telegram.

One script, one `onboard` command, and you have a headless AI bot running on a $35 board that answers your messages around the clock.

---

## Why a Pi?

- **Always on** — draws ~5W, runs 24/7 on your desk or closet shelf
- **Private** — your API key, your Pi, your Tailscale network, no cloud middleman
- **Portable** — fits in your pocket, works anywhere with WiFi
- **Cheap** — Raspberry Pi 4B (4 GB) + 32 GB SD card is all you need
- **Monitorable** — pair with [clawpi-scout](https://github.com/BigDawg013/clawpi-scout) for physical LED dashboard + Telegram health alerts

---

## Architecture

```
   You (anywhere)
       |
       | Telegram message
       v
+------+-------+
| Telegram Bot  |
| @your_bot     |
+------+--------+
       |
       v
+------+----------------------------+
|  Raspberry Pi  ·  clawpi-ai       |
|                                    |
|  OpenClaw Gateway (port 18789)     |
|  Bound to Tailscale IP             |
|  systemd service (auto-restart)    |
|                                    |
|  Plugins: telegram, memory, voice  |
+------+----------------------------+
       |
       | Tailscale mesh (encrypted)
       |
+------+----------------------------+     +-----------------------------+
|  Mac Mini  ·  ClawBot #1          |     |  Raspberry Pi  ·  Scout     |
|  OpenClaw (primary workstation)    |     |  clawpi-scout               |
|  ws://localhost:18789              |     |  Monitors gateway health    |
+-----------------------------------+     |  LED dashboard + alerts     |
                                          +-----------------------------+
```

All devices connected via [Tailscale](https://tailscale.com) — accessible from anywhere, encrypted end-to-end.

---

## Quick start

### 1. Flash and connect

Flash **Raspberry Pi OS Lite (64-bit)** with SSH enabled, boot the Pi, and SSH in.

### 2. Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### 3. Clone and install

```bash
git clone https://github.com/BigDawg013/clawpi-ai.git ~/clawpi-ai
cd ~/clawpi-ai
chmod +x scripts/install.sh && ./scripts/install.sh
```

### 4. Onboard OpenClaw

```bash
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
```

### 5. Enable Telegram

```bash
openclaw plugins enable telegram
systemctl --user restart openclaw-gateway
openclaw channels add --channel telegram --token "YOUR_BOT_TOKEN"
```

### 6. Pair your account

Send `/start` to your bot on Telegram, then approve the pairing code:

```bash
openclaw pairing list --channel telegram
openclaw pairing approve <CODE> --channel telegram
```

Send a message to your bot — it replies. You're done.

---

## What's in this repo

```
clawpi-ai/
├── scripts/
│   └── install.sh                # Installs Node.js 22 + OpenClaw + pnpm
├── config/
│   └── openclaw.json.example     # Annotated config template (no secrets)
├── docs/
│   └── SETUP.md                  # Detailed step-by-step guide
├── LICENSE
└── README.md
```

The actual OpenClaw config lives at `~/.openclaw/openclaw.json` on the Pi (gitignored, contains your API key and tokens).

---

## Key commands

```bash
openclaw gateway status                          # Gateway health + RPC probe
openclaw channels status                         # Telegram channel status
openclaw logs                                    # Live gateway logs
openclaw doctor                                  # Full system health check

systemctl --user restart openclaw-gateway        # Restart gateway
systemctl --user status openclaw-gateway         # systemd service status

sudo npm i -g openclaw@latest                    # Update OpenClaw
```

---

## Configuration

See [`config/openclaw.json.example`](config/openclaw.json.example) for an annotated config template.

| Setting | Value | Purpose |
|---------|-------|---------|
| `gateway.port` | `18789` | WebSocket gateway port |
| `gateway.bind` | `tailnet` | Bind to Tailscale IP (not localhost) |
| `gateway.auth.mode` | `token` | Token-based gateway authentication |
| `channels.telegram.dmPolicy` | `pairing` | Require pairing code for DMs |
| `channels.telegram.groupPolicy` | `allowlist` | Only respond in approved groups |
| `agents.defaults.maxConcurrent` | `4` | Max concurrent agent sessions |

Change settings:

```bash
openclaw config set gateway.bind tailnet
systemctl --user restart openclaw-gateway
```

---

## Pairing with clawpi-scout

If you have a second Pi running [clawpi-scout](https://github.com/BigDawg013/clawpi-scout), point its config at this Pi's Tailscale IP:

```yaml
# config/scout.yaml on the scout Pi
gateway:
  url: "http://<CLAWPI_TAILSCALE_IP>:18789"
  health_interval: 60
  timeout: 10
  max_failures: 3
```

The scout pings the gateway every 60 seconds. If it goes down, you get a Telegram alert and the physical LED dashboard lights up red.

---

## Related

- **[clawpi-scout](https://github.com/BigDawg013/clawpi-scout)** — GPIO health monitor with LEDs, LCD, bar graph, 7-segment, dot matrix
- **[OpenClaw](https://openclaw.ai)** — The multi-agent AI platform powering this bot

---

## License

[MIT](LICENSE)
