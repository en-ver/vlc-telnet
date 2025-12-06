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
| `ALSA_DEVICE`         | No       | Auto-detected | USB audio device path from `/dev/snd/by-id/`. Auto-detects USB audio if not set |

## USB Speaker Configuration

**Important**: Only use device paths from `/dev/snd/by-id/` for stable audio device configuration.

### Finding Your USB Audio Device

1. **Find your USB audio device:**

   ```bash
   ls -la /dev/snd/by-id/
   ```

2. **Copy the device path** (example output):

   ```
   usb-0b0e_Jabra_Speak_710_70BF92A31827-00 -> ../card1
   ```

3. **Set the ALSA_DEVICE variable in your .env file:**
   ```
   VLC_TELNET_PASSWORD=your_secure_password_here
   ALSA_DEVICE=/dev/snd/by-id/usb-0b0e_Jabra_Speak_710_70BF92A31827-00
   ```

### Auto-Detection

If `ALSA_DEVICE` is not specified, the container will:

1. Search for devices containing "USB Audio"
2. Use the first found USB audio device
3. Apply the format `hw:X,Y` automatically

**Note**: Using `/dev/snd/by-id/` paths is recommended over `hw:X,Y` format as these IDs remain consistent across reboots.

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

1. Find the new device: `ls -la /dev/snd/by-id/`
2. Update the `ALSA_DEVICE` in your .env file with the new device path

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
