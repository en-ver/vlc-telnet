#!/bin/sh

# Set the search keyword (default to "USB Audio" if not specified)
if [ -n "$ALSA_DEVICE" ]; then
    search_keyword="$ALSA_DEVICE"
    echo "Searching for audio device with keyword: $search_keyword"
else
    search_keyword="USB Audio"
    echo "No ALSA_DEVICE specified, using default keyword: $search_keyword"
fi

# Find the ALSA device using the keyword
alsa_device=$(aplay -l | grep -i "$search_keyword" | head -n1 | cut -d ' ' -f2 | sed 's/://')

if [ -n "$alsa_device" ]; then
    echo "Found audio device: $alsa_device"
else
    echo "No device found matching keyword: $search_keyword"
    echo "Available devices:"
    aplay -l
    exit 1
fi

# Execute VLC with configured ALSA device
exec vlc --no-video --no-dbus --intf telnet --telnet-password $VLC_TELNET_PASSWORD --alsa-audio-device hw:$alsa_device
