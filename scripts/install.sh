#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# clawpi-ai installer
# Sets up Node.js, OpenClaw, and systemd service
# on a Raspberry Pi running Debian/Raspberry Pi OS.
# ──────────────────────────────────────────────

echo "═══════════════════════════════════════════"
echo "  clawpi-ai installer"
echo "═══════════════════════════════════════════"

# ── Node.js ──────────────────────────────────
if command -v node &>/dev/null; then
    echo "✓ Node.js already installed: $(node --version)"
else
    echo "Installing Node.js 22 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✓ Node.js installed: $(node --version)"
fi

# ── OpenClaw ─────────────────────────────────
if command -v openclaw &>/dev/null; then
    echo "✓ OpenClaw already installed: $(openclaw --version)"
else
    echo "Installing OpenClaw..."
    sudo npm i -g openclaw
    echo "✓ OpenClaw installed: $(openclaw --version)"
fi

# ── Systemd service ──────────────────────────
SERVICE_FILE="/etc/systemd/system/clawpi-ai.service"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$SERVICE_FILE" ]; then
    echo "✓ systemd service already exists"
else
    echo "Creating systemd service..."
    sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=clawpi-ai — OpenClaw AI assistant
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=/home/$(whoami)
ExecStart=/usr/bin/openclaw serve
Restart=on-failure
RestartSec=10
EnvironmentFile=-/home/$(whoami)/clawpi-ai/scripts/openclaw.env

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    echo "✓ systemd service created"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Next steps:"
echo "  1. Run: openclaw onboard"
echo "  2. Run: sudo systemctl enable --now clawpi-ai"
echo "═══════════════════════════════════════════"
