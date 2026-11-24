#!/bin/bash
# Byter ljudutgång: ./scripts/switch-output.sh hdmi|analog
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
case "${1:-}" in
  hdmi)   sudo install -m 0644 "$REPO/config/shairport-sync.hdmi.conf" /etc/shairport-sync.conf ;;
  analog) amixer -c Headphones sset PCM 0dB >/dev/null && sudo alsactl store
          sudo install -m 0644 "$REPO/config/shairport-sync.analog.conf" /etc/shairport-sync.conf ;;
  *) echo "Användning: $0 hdmi|analog"; exit 1 ;;
esac
sudo systemctl restart shairport-sync
echo "Ljudutgång: $1"
