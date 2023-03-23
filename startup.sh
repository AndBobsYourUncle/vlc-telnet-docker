#!/bin/bash

# Assert env variable
if [ -z "$TELNET_PASSWORD" ]; then
  echo "ERROR: 'TELNET_PASSWORD' env variable is not defined"
  exit 1
fi

# Set default values
export SOUND_CARD_NUMBER="${SOUND_CARD_NUMBER:-0}"
export VOLUME_LEVEL_PERCENT="${VOLUME_LEVEL_PERCENT:-100}"
export VOLUME_CHANNEL="${VOLUME_CHANNEL:-Master}"

# Set default sound card for VLC
echo "defaults.pcm.card $SOUND_CARD_NUMBER" >> /etc/asound.conf
echo "defaults.ctl.card $SOUND_CARD_NUMBER" >> /etc/asound.conf

# Set volume level in percents
amixer set "$VOLUME_CHANNEL" "$VOLUME_LEVEL_PERCENT"%

signalListener() {
    "$@" &
    pid="$!"
    trap "echo 'Stopping PID $pid'; kill -SIGTERM $pid" SIGINT SIGTERM

    # A signal emitted while waiting will make the wait command return code > 128
    # Let's wrap it in a loop that doesn't end before the process is indeed stopped
    while kill -0 $pid > /dev/null 2>&1; do
        wait
    done
}

# Run VLC with telnet interface as a non-root "vlcuser" user
signalListener su -c "vlc -I telnet --no-dbus --aout=Alsa --telnet-password $TELNET_PASSWORD" vlcuser
