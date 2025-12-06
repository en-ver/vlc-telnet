#!/bin/sh

# Function to convert /dev/snd/by-id/ path to hw:X,Y format
convert_by_id_to_hw() {
    local by_id_path="$1"
    local card_num

    # Check if the provided path exists and is a symlink
    if [ -L "$by_id_path" ]; then
        # Resolve the symlink to get the card path
        local card_path=$(readlink "$by_id_path")
        # Extract card number from path (e.g., "../card1" -> "1")
        card_num=$(echo "$card_path" | sed 's/.*card\([0-9]*\).*/\1/')

        if [ -n "$card_num" ]; then
            # Get device number for this card (usually 0 for USB audio)
            local device_num=$(aplay -l | grep "card $card_num:" | head -n1 | sed 's/.*device \([0-9]*\):.*/\1/')
            if [ -z "$device_num" ]; then
                device_num="0"
            fi
            echo "hw:$card_num,$device_num"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Function to get card ID from card number
get_card_id() {
    local card_num="$1"
    cat /proc/asound/cards | grep "^\s*$card_num\s" | awk '{print $NF}'
}

# Use provided ALSA device or fall back to auto-detection
if [ -n "$ALSA_DEVICE" ]; then
    if echo "$ALSA_DEVICE" | grep -q "/dev/snd/by-id/"; then
        # Convert /dev/snd/by-id/ path to hw:X,Y format
        audio_device=$(convert_by_id_to_hw "$ALSA_DEVICE")
        if [ -n "$audio_device" ]; then
            echo "Converted device path $ALSA_DEVICE to ALSA format: $audio_device"

            # Also try to get card ID for more stable identification
            card_num=$(echo "$audio_device" | sed 's/hw:\([0-9]*\),.*/\1/')
            card_id=$(get_card_id "$card_num")
            if [ -n "$card_id" ]; then
                echo "Alternative stable device name: hw:$card_id,0"
            fi
        else
            echo "Failed to convert device path $ALSA_DEVICE, falling back to auto-detection"
            alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
            audio_device="hw:$alsa_device"
            echo "Auto-detected ALSA device: $audio_device"
        fi
    else
        # Use the provided device as-is (assumes hw:X,Y format)
        audio_device="$ALSA_DEVICE"
        echo "Using configured ALSA device: $audio_device"
    fi
else
    # Auto-detection fallback
    alsa_device=$(aplay -l | grep -i 'USB Audio' | head -n1 | cut -d ' ' -f2 | sed 's/://')
    audio_device="hw:$alsa_device"
    echo "Auto-detected ALSA device: $audio_device"
fi

# Execute VLC with configured ALSA device
exec vlc --no-video --no-dbus --intf telnet --telnet-password $VLC_TELNET_PASSWORD --alsa-audio-device $audio_device
