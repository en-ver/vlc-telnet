#!/bin/sh

# Set the alsa_device variable
alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')

# Execute VLC with configured ALSA device
exec vlc --no-video --no-dbus --intf telnet --telnet-password $VLC_TELNET_PASSWORD --alsa-audio-device hw:$alsa_device
