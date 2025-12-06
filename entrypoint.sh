#!/bin/sh

# Function to convert /dev/snd/by-id/ path to hw:X,Y format
convert_by_id_to_hw() {
    local by_id_path="$1"

    # Check if the provided path exists and is a symlink
    if [ -L "$by_id_path" ]; then
        # Resolve the symlink to get the actual ALSA device node
        local device_node=$(readlink -f "$by_id_path")
        echo "Resolved symlink: $device_node"

        # Extract card number (C) and device number (D) from device node
        # Pattern matching: pcmC1D0p -> card=1, device=0
        if echo "$device_node" | grep -q "pcmC\([0-9]*\)D\([0-9]*\)"; then
            local card_num=$(echo "$device_node" | sed 's/.*pcmC\([0-9]*\)D\([0-9]*\).*/\1/')
            local device_num=$(echo "$device_node" | sed 's/.*pcmC\([0-9]*\)D\([0-9]*\).*/\2/')
            echo "hw:$card_num,$device_num"
        elif echo "$device_node" | grep -q "controlC\([0-9]*\)"; then
            # For control devices, assume device 0
            local card_num=$(echo "$device_node" | sed 's/.*controlC\([0-9]*\).*/\1/')
            echo "hw:$card_num,0"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Use provided ALSA device or fall back to auto-detection
if [ -n "$ALSA_DEVICE" ]; then
    if echo "$ALSA_DEVICE" | grep -q "/dev/snd/by-id/"; then
        # Convert /dev/snd/by-id/ path to hw:X,Y format
        audio_device=$(convert_by_id_to_hw "$ALSA_DEVICE")
        if [ -n "$audio_device" ]; then
            echo "Successfully converted $ALSA_DEVICE to ALSA format: $audio_device"
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
