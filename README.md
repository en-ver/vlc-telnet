# vlc-telnet

A Docker image of VLC with Telnet interface for remote control, designed for **Home Assistant users to play audio through any speakers**.

## Overview

This container enables Home Assistant to play audio through any connected speakers via VLC's Telnet interface. It supports USB speakers, HDMI audio, built-in audio, and any ALSA-compatible devices.

**Key Features:**

- **Home Assistant Integration**: Perfect companion for VLC Telnet integration
- **Universal Audio Support**: Works with USB, HDMI, built-in, and any ALSA-compatible device
- **Audio-Only Mode**: Optimized for audio playback (no video)
- **Remote Control**: Full VLC control via Telnet on port 4212
- **Secure**: Password-protected access

## Quick Start

### Prerequisites

- Docker or Docker Compose installed
- Audio speakers connected to host (USB, HDMI, built-in, etc.)
- Home Assistant instance

### Setup

1. **Create environment file:**

   ```bash
   cp .env.template .env
   ```

2. **Edit .env with your values:**

   ```bash
   VLC_TELNET_PASSWORD=your_secure_password
   ALSA_DEVICE=J710  # Your audio device keyword
   ```

3. **Run with Docker Compose:**

   ```yaml
   services:
     vlc-telnet:
       image: ne1ver/vlc-telnet
       container_name: vlc-telnet
       ports:
         - "4212:4212"
       devices:
         - "/dev/snd:/dev/snd"
       environment:
         - VLC_TELNET_PASSWORD=${VLC_TELNET_PASSWORD}
         - ALSA_DEVICE=${ALSA_DEVICE}
       restart: unless-stopped
   ```

4. **Start the container:**
   ```bash
   docker-compose up -d
   ```

## Audio Device Configuration

### Find Your Audio Device

1. **List audio cards on host:**

   ```bash
   cat /proc/asound/cards
   ```

2. **Find your device in output:**

   ```bash
   0 [J710           ]: USB-Audio - Jabra Speak 710
   1 [HDMI           ]: HDA-Intel - HDA ATI HDMI
   2 [PCH            ]: HDA-Intel - HD-Audio Generic
   ```

3. **Set ALSA_DEVICE with unique keywords from your device name:**
   - `J710` for Jabra Speak 710
   - `HDMI` for HDMI audio
   - `PCH` for built-in audio

### Environment Variables

| Variable              | Required | Default     | Description                            |
| --------------------- | -------- | ----------- | -------------------------------------- |
| `VLC_TELNET_PASSWORD` | Yes      | None        | Telnet access password                 |
| `ALSA_DEVICE`         | No       | "USB Audio" | Keywords to identify your audio device |

**How it works:** The container uses your keywords to search for the matching audio device and configures it for VLC.

## Home Assistant Configuration

Add to your `configuration.yaml`:

```yaml
media_player:
  - platform: vlc_telnet
    host: localhost
    port: 4212
    password: your_secure_password
    name: Audio Speakers
```

Or add via UI: Settings → Devices & Services → Add Integration → "VLC Telnet"

## Important Notes

- **Single Device**: Use one audio device at a time
- **Unique Keywords**: Use specific keywords like `J710` instead of generic terms like `USB`
- **Security**: Use strong password and limit network exposure

## Troubleshooting

### No Audio Output

1. Check container logs for device detection results
2. Verify `/dev/snd:/dev/snd` device mapping
3. Update `ALSA_DEVICE` with correct keywords from `cat /proc/asound/cards`

### Device Changes After Reboot

If audio stops working:

1. Run `cat /proc/asound/cards` on host
2. Update `ALSA_DEVICE` with correct keywords

## Example Home Assistant Automations

**Play announcement:**

```yaml
service: media_player.play_media
target:
  entity_id: media_player.audio_speakers
data:
  media_content_id: /config/www/audio/announcement.mp3
  media_content_type: music
```

**Volume control:**

```yaml
service: media_player.volume_set
target:
  entity_id: media_player.audio_speakers
data:
  volume_level: 0.5
```

## Project Links

- **Docker Hub**: https://hub.docker.com/r/ne1ver/vlc-telnet
- **GitHub Repository**: https://github.com/en-ver/vlc-telnet
- **Home Assistant VLC Integration**: https://www.home-assistant.io/integrations/vlc_telnet/

---

**Disclaimer**: This image is provided as-is. Use at your own risk.
