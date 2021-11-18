#!/bin/sh
OPTIONS="--no-sandbox -test-type"
CHROME=$(which google-chrome)
export DISPLAY=:0
$CHROME $OPTIONS
