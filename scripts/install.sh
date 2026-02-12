#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# clawpi-ai installer
# Sets up Node.js, OpenClaw, and pnpm on a
# Raspberry Pi running Debian / Raspberry Pi OS.
#
# Usage: chmod +x scripts/install.sh && ./scripts/install.sh
# ──────────────────────────────────────────────

echo "═══════════════════════════════════════════"
echo "  clawpi-ai installer"
echo "═══════════════════════════════════════════"
echo ""

# ── Node.js ──────────────────────────────────
if command -v node &>/dev/null; then
    echo "✓ Node.js already installed: $(node --version)"
else
    echo "Installing Node.js 22 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✓ Node.js installed: $(node --version)"
fi

# ── pnpm ─────────────────────────────────────
if command -v pnpm &>/dev/null; then
    echo "✓ pnpm already installed: $(pnpm --version)"
else
    echo "Installing pnpm..."
    sudo npm i -g pnpm
    echo "✓ pnpm installed: $(pnpm --version)"
fi

# ── OpenClaw ─────────────────────────────────
if command -v openclaw &>/dev/null; then
    echo "✓ OpenClaw already installed: $(openclaw --version)"
else
    echo "Installing OpenClaw..."
    sudo npm i -g openclaw
    echo "✓ OpenClaw installed: $(openclaw --version)"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Next steps:"
echo "    1. Run onboarding (see docs/SETUP.md step 4)"
echo "    2. Enable Telegram (see docs/SETUP.md step 5)"
echo "═══════════════════════════════════════════"
