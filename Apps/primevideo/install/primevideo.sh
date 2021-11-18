#!/bin/bash
OPTIONS="--no-sandbox -test-type --app=https://www.primevideo.com/ "
CHROME=$(which google-chrome)
export DISPLAY=:0
$CHROME $OPTIONS &
PID=$!

for ((i=1; i<10; i++)); do
        if [ ! -z "$(xdotool search --name "Prime Video")" ] ; then
                xdotool key --window $(xdotool search --name "Prime Video") F11
                break
        fi
  sleep 1
done
wait $PID

