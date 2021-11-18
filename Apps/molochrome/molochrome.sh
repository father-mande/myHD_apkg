#!/bin/bash
OPTIONS="--no-sandbox --app=https://app.molotov.tv/ "
CHROME=$(which google-chrome)
export DISPLAY=:0
$CHROME "$OPTIONS" &
PID=$!

for ((i=1; i<10; i++)); do
        if [ ! -z "$(xdotool search --name Molotov)" ] ; then
                xdotool key --window $(xdotool search --name Molotov) F11
                break
        fi
  sleep 1
done
wait $PID

