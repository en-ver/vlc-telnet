#!/bin/sh

# Function to find card number using keywords from /proc/asound/cards
find_card_by_keywords() {
    local keywords="$1"

    # Get the card number matching the keywords
    local card_num=$(cat /proc/asound/cards | grep -i "$keywords" | head -n1 | sed 's/^\s*\([0-9]*\).*/\1/')

    if [ -n "$card_num" ]; then
        echo "$card_num"
    else
        echo ""
    fi
}

# Use provided ALSA device or fall back to auto-detection
if [ -n "$ALSA_DEVICE" ]; then
    if echo "$ALSA_DEVICE" | grep -q "/dev/snd/by-id/"; then
        echo "Device path detection is deprecated. Please use keywords from /proc/asound/cards instead."
        echo "Example: ALSA_DEVICE=J710 or ALSA_DEVICE=Jabra"

        # Fallback to USB Audio keyword detection
        alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
        audio_device="hw:$alsa_device"
        echo "Using fallback auto-detection: $audio_device"
    elif echo "$ALSA_DEVICE" | grep -q "hw:"; then
        # Use the provided hw:X,Y format directly
        audio_device="$ALSA_DEVICE"
        echo "Using configured ALSA device: $audio_device"
    else
        # Treat ALSA_DEVICE as keywords to find the card
        card_num=$(find_card_by_keywords "$ALSA_DEVICE")
        if [ -n "$card_num" ]; then
            audio_device="hw:$card_num,0"
            echo "Found card '$ALSA_DEVICE' as card $card_num, using: $audio_device"
        else
            echo "No card found matching keywords: $ALSA_DEVICE"
            echo "Available cards:"
            cat /proc/asound/cards
            echo "Falling back to auto-detection..."
            alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
            audio_device="hw:$alsa_device"
            echo "Auto-detected ALSA device: $audio_device"
        fi
    fi
else
    # Auto-detection fallback - use keywords approach
    card_num=$(find_card_by_keywords "USB")
    if [ -n "$card_num" ]; then
        audio_device="hw:$card_num,0"
        echo "Auto-detected USB audio card as card $card_num, using: $audio_device"
    else
        echo "No USB audio card found, falling back to legacy method..."
        alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
        audio_device="hw:$alsa_device"
        echo "Auto-detected ALSA device: $audio_device"
    fi
fi

# Execute VLC with configured ALSA device
exec vlc --no-video --no-dbus --intf telnet --telnet-password $VLC_TELNET_PASSWORD --alsa-audio-device $audio_device
