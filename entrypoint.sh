#!/bin/sh

# Use provided ALSA device or fall back to auto-detection
if [ -n "$ALSA_DEVICE" ]; then
    audio_device="$ALSA_DEVICE"
    echo "Using configured ALSA device: $audio_device"
else
    alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
    audio_device="hw:$alsa_device"
    echo "Auto-detected ALSA device: $audio_device"
fi

# Execute VLC with configured ALSA device
exec vlc --no-video --no-dbus --intf telnet --telnet-password $VLC_TELNET_PASSWORD --alsa-audio-device $audio_device
