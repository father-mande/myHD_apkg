#!/bin/bash
OPTIONS="--no-sandbox -test-type https://open.spotify.com/browse/featured "
CHROME=$(which google-chrome)
export DISPLAY=:0
$CHROME $OPTIONS &
PID=$!

for ((i=1; i<10; i++)); do
        if [ ! -z "$(xdotool search --name "Spotify")" ] ; then
                xdotool key --window $(xdotool search --name "Spotify") F11
                break
        fi
  sleep 1
done
wait $PID

