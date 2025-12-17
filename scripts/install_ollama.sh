#!/usr/bin/env bash
#
# install_ollama.sh - Install official Ollama with ROCm support
#
# Background:
# -----------
# The Ollama binary installed via Mise/Aqua doesn't include ROCm GPU libraries.
# It only bundles CUDA (NVIDIA) support. For AMD Radeon GPUs like the RX 7900 XTX,
# we need the official Ollama release which includes pre-compiled ROCm libraries.
#
# What this script does:
# ----------------------
# 1. Downloads the official Ollama installer from ollama.com
# 2. Installs Ollama system-wide to /usr/local/bin/
# 3. Sets up systemd service for automatic startup (optional)
# 4. Includes ROCm 6.x libraries needed for AMD GPU acceleration
#
# After installation:
# -------------------
# - The official /usr/local/bin/ollama will have priority over Mise version
# - ROCm libraries will be bundled at /usr/local/lib/ollama/
# - GPU should be automatically detected on next start
# - No need to manually set HSA_OVERRIDE_GFX_VERSION for RX 7900 XTX
#
# Usage:
# ------
# chmod +x scripts/install_ollama.sh
# ./scripts/install_ollama.sh
#

set -euo pipefail

echo "==> Installing official Ollama with ROCm support..."
echo ""
echo "This replaces the Mise/Aqua version which lacks AMD GPU support."
echo "The official version includes pre-compiled ROCm 6.x libraries."
echo ""

# Download and run the official installer
curl -fsSL https://ollama.com/install.sh | sh

echo ""
echo "==> Installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart your shell or run: hash -r"
echo "2. Verify GPU detection: ollama serve"
echo "3. In another terminal, run a model: ollama run qwen3-coder:30b"
echo "4. Monitor GPU usage: watch -n 1 cat /sys/class/drm/card0/device/gpu_busy_percent"
echo ""
echo "If GPU is still not detected:"
echo "- Check logs: journalctl -u ollama -f"
echo "- Try setting: export HSA_OVERRIDE_GFX_VERSION=11.0.0"
echo "- Verify ROCm libraries: ls /usr/local/lib/ollama/ | grep rocm"
