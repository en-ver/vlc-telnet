# vlc-telnet

A Docker image of VLC with a Telnet interface for remote control, specifically designed for **Home Assistant users who want to play audio files through USB speakers**.

## Overview

This container enables Home Assistant to play audio through USB speakers via VLC's Telnet interface. It's optimized for audio-only playback with automatic USB audio device detection.

**Key Features:**

- **Home Assistant Integration**: Perfect companion for the VLC Telnet integration
- **USB Speaker Support**: Auto-detects and configures USB audio devices
- **Audio-Only Mode**: Optimized for audio playback (no video component)
- **Remote Control**: Full VLC control through Telnet on port 4212
- **Secure**: Password-protected Telnet access

## Quick Start

### Prerequisites

- Docker or Docker Compose installed
- USB speakers connected to your host system
- Home Assistant instance (for integration)

### Environment Setup

**It's recommended to create a .env file from the provided template:**

```bash
# Create .env file from template
cp .env.template .env
# Edit .env with your specific values
```

### Docker Compose (Recommended)

Create a `docker-compose.yml` file:

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

### Docker Run

```bash
docker run -d \
  --name vlc-telnet \
  -p 4212:4212 \
  --device /dev/snd:/dev/snd \
  -e VLC_TELNET_PASSWORD=your_secure_password_here \
  ne1ver/vlc-telnet
```

## Home Assistant Configuration

Add the VLC Telnet integration to your `configuration.yaml`:

```yaml
# configuration.yaml
media_player:
  - platform: vlc_telnet
    host: localhost # or your host's IP address
    port: 4212
    password: your_secure_password_here
    name: USB Speakers
```

Or add through the UI:

1. Go to **Settings** → **Devices & Services**
2. Click **+ Add Integration**
3. Search for "VLC Telnet"
4. Enter the connection details

## Environment Variables

| Variable              | Required | Default       | Description                                                                     |
| --------------------- | -------- | ------------- | ------------------------------------------------------------------------------- |
| `VLC_TELNET_PASSWORD` | Yes      | None          | Password for Telnet access (use a strong password)                              |
| `ALSA_DEVICE`         | No       | Auto-detected | Keywords to search for in `aplay -l` output. Examples: `J710`, `Jabra`, `USB Audio`. Defaults to "USB Audio" if not set |

## USB Speaker Configuration

**Important**: Use keywords from `/proc/asound/cards` (host command) to identify your audio device. The container will use these keywords to search `aplay -l` output internally.

### Finding Your USB Audio Device

1. **List available audio cards on the host machine:**

   ```bash
   cat /proc/asound/cards
   ```

2. **Identify your device from the output** (example):

   ```
   0 [J710           ]: USB-Audio - Jabra Speak 710
                        Jabra Speak 710 at usb-0000:00:12.0-1.1, full speed
   1 [HDMI           ]: HDA-Intel - HDA ATI HDMI
   2 [Generic        ]: HDA-Intel - HD-Audio Generic
   ```

3. **Set the ALSA_DEVICE variable in your .env file with keywords from the card name:**
   ```
   VLC_TELNET_PASSWORD=your_secure_password_here
   ALSA_DEVICE=J710
   ```

**Alternative keywords for the same device:**
- `J710` (card identifier - recommended)
- `Jabra` (device brand)
- `Speak` (device model)
- `USB Audio` (device description - default)

### How It Works

- **You**: Use `cat /proc/asound/cards` on host to find keywords
- **Container**: Uses those keywords to search `aplay -l` output internally
- **Result**: Finds the matching device and uses `hw:X,Y` format for VLC

### Auto-Detection

If `ALSA_DEVICE` is not specified, the container will:

1. Search `aplay -l` output for devices containing "USB Audio"
2. Use the first matching device
3. Apply the format `hw:X,Y` automatically

**Note**: Using unique keywords (like `J710`) is more reliable than generic terms (`USB`) when multiple audio devices are present.

## Important Notes

### USB Speaker Limitations

- **Single Speaker**: Use only one USB speaker at a time
- **Device Stability**: USB device numbers can change after reboots - use device by ID when possible
- **Audio Group**: The container runs as a user with audio group permissions for device access

### Security

- **Strong Password**: Always use a strong, unique `VLC_TELNET_PASSWORD`
- **Network Access**: Only expose port 4212 if needed for remote access
- **Local Use**: Recommended for local network use only

### Multi-Architecture Support

This image supports multiple architectures:

- `linux/amd64`
- `linux/arm64`
- `linux/arm/v7`

## Troubleshooting

### No Audio Output

1. **Check device mapping**: Ensure `/dev/snd:/dev/snd` is properly mapped
2. **Verify USB device**: Check container logs for auto-detection results
3. **Manual device**: Specify `ALSA_DEVICE` manually using the path from `ls -la /dev/snd/by-id/`

### Permission Issues

1. **Docker permissions**: Ensure Docker has access to audio devices
2. **User permissions**: Container runs as non-root user with audio group access

### Device Changes After Reboot

If audio stops working after restart:

1. Check available cards on host: `cat /proc/asound/cards`
2. Update the `ALSA_DEVICE` in your .env file with the correct keywords for your device

## Example Home Assistant Automations

**Play announcement:**

```yaml
service: media_player.play_media
target:
  entity_id: media_player.usb_speakers
data:
  media_content_id: /config/www/audio/announcement.mp3
  media_content_type: music
```

**Volume control:**

```yaml
service: media_player.volume_set
target:
  entity_id: media_player.usb_speakers
data:
  volume_level: 0.5
```

## Project Links

- **Docker Hub**: https://hub.docker.com/r/ne1ver/vlc-telnet
- **GitHub Repository**: https://github.com/en-ver/vlc-telnet
- **Home Assistant VLC Telnet Integration**: https://www.home-assistant.io/integrations/vlc_telnet/

---

**Disclaimer**: This image is provided as-is, with no guarantee of suitability for any specific purpose. Use at your own risk.
