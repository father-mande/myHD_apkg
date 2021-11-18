#!/bin/sh

XTERM=$(which xterm)
export DISPLAY=:0
$XTERM -title "test using Xterm" -fn 9x15bold -e /bin/bash

