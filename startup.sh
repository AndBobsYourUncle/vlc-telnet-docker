#!/bin/bash

# Assert env variable
if [ -z "$TELNET_PASSWORD" ]; then
  echo "ERROR: 'TELNET_PASSWORD' env variable is not defined"
  exit 1
fi

# Set default values
SOUND_CARD_NUMBER="${SOUND_CARD_NUMBER:-0}"
VOLUME_LEVEL_PERCENT="${VOLUME_LEVEL_PERCENT:-100}"
VOLUME_CHANNEL="${VOLUME_CHANNEL:-Master}"

# Set default sound card for VLC
echo "defaults.pcm.card $SOUND_CARD_NUMBER" >> /etc/asound.conf
echo "defaults.ctl.card $SOUND_CARD_NUMBER" >> /etc/asound.conf

# Set volume level in percents
amixer set "$VOLUME_CHANNEL" "$VOLUME_LEVEL_PERCENT"%

#--- we add a function to exit nicely (perhaps kill a few processes and remove some temp files)
function exit_container_SIGTERM(){
  echo "Caught SIGTERM"
  exit 0
}

#--- trap the SIGTERM signal
trap exit_container_SIGTERM SIGTERM

# Run VLC with telnet interface as a non-root "vlcuser" user
vlc -I telnet --no-dbus --aout=Alsa --telnet-password $TELNET_PASSWORD
