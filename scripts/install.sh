#!/bin/bash
# Installerar NQPTP och Shairport Sync med AirPlay 2 på Raspberry Pi OS Lite 32-bit (Trixie)
# Användning: ./scripts/install.sh [hdmi|analog]
set -euo pipefail
MODE="${1:-hdmi}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

sudo apt update
sudo apt install -y --no-install-recommends build-essential git autoconf automake libtool \
  libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev \
  libsoxr-dev libplist-dev libplist-utils libsodium-dev libavutil-dev libavcodec-dev \
  libavformat-dev uuid-dev libgcrypt20-dev xxd systemd-dev

cd ~
[ -d nqptp ] || git clone https://github.com/mikebrady/nqptp.git
cd nqptp && git pull && autoreconf -fi && ./configure --with-systemd-startup && make && sudo make install
sudo systemctl enable --now nqptp

cd ~
[ -d shairport-sync ] || git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync && git pull && autoreconf -fi
./configure --sysconfdir=/etc --with-alsa --with-soxr --with-avahi --with-ssl=openssl \
  --with-systemd-startup --with-airplay-2
make -j2 && sudo make install

if [ "$MODE" = "hdmi" ]; then
  sudo install -m 0644 "$REPO/firmware/edid-nad.bin" /lib/firmware/edid-nad.bin
  CMDLINE=/boot/firmware/cmdline.txt
  grep -q 'video=HDMI-A-1' "$CMDLINE" || sudo sed -i 's/$/ video=HDMI-A-1:1280x720@60D/' "$CMDLINE"
  grep -q 'drm.edid_firmware' "$CMDLINE" || sudo sed -i 's/$/ drm.edid_firmware=HDMI-A-1:edid-nad.bin/' "$CMDLINE"
  sudo install -m 0644 "$REPO/config/shairport-sync.hdmi.conf" /etc/shairport-sync.conf
else
  amixer -c Headphones sset PCM 0dB && sudo alsactl store
  sudo install -m 0644 "$REPO/config/shairport-sync.analog.conf" /etc/shairport-sync.conf
fi

sudo systemctl enable --now shairport-sync
sudo systemctl restart shairport-sync
shairport-sync -V
echo "Klart. HDMI-läge kräver omstart (sudo reboot) första gången."
