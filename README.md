# airplay2rpi

AirPlay 2-mottagare på en Raspberry Pi 2 Model B V1.1 för NAD T737 (HDMI) eller Geneva (analog 3,5 mm).

## Status

- Raspberry Pi OS Lite 32-bit (Trixie), kärna 6.18
- NQPTP och Shairport Sync 5.6.3 med AirPlay 2, byggda från källkod
- Syns som **airplay2rpi** i AirPlay. Volymen styrs på receivern/högtalaren.
- Återstår: RS232-styrning av T737 (power, källa, volym) och Home Assistant.

## Installation

1. Skriv Raspberry Pi OS Lite (32-bit) med Raspberry Pi Imager, enhet Raspberry Pi 2, med användare och SSH.
   I macOS måste Imager ha behörighet till flyttbara volymer (Integritet och säkerhet).
2. Logga in, klona repot och kör:

   ```bash
   git clone https://github.com/<konto>/airplay2rpi.git
   cd airplay2rpi
   ./scripts/install.sh hdmi      # eller: analog
   sudo reboot                    # krävs första gången i HDMI-läge
   ```

## Byta ljudutgång

```bash
./scripts/switch-output.sh hdmi     # NAD T737
./scripts/switch-output.sh analog   # Geneva
```

## HDMI-ljud och EDID

NAD T737 (2008) skickar ingen EDID. Utan EDID behandlar Pi:n utgången som DVI och vägrar HDMI-ljud
(`Playback open error: -524`). `firmware/edid-nad.bin` är en egen EDID (720p, HDMI, LPCM stereo
32/44,1/48 kHz). Installationsskriptet lägger den i `/lib/firmware/` och lägger till i
`/boot/firmware/cmdline.txt`:

```
video=HDMI-A-1:1280x720@60D drm.edid_firmware=HDMI-A-1:edid-nad.bin
```

Kontroll efter omstart: `wc -c /sys/class/drm/card0-HDMI-A-1/edid` ska visa 256.

## Filer

| Fil | Innehåll |
| --- | --- |
| `config/shairport-sync.hdmi.conf` | Konfiguration för NAD T737 via HDMI |
| `config/shairport-sync.analog.conf` | Konfiguration för Geneva via 3,5 mm |
| `firmware/edid-nad.bin` | Egen EDID med HDMI-ljudstöd |
| `scripts/install.sh` | Installerar allt från ett nytt kort |
| `scripts/switch-output.sh` | Byter mellan HDMI och analog utgång |
