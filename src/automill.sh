#!/bin/bash

# Usage
# automill.sh project outputfile bbox minzoon maxzoom

# project name
# output file (no mbtiles extension)
# bbox (left,bottom,right,top)
# min zoom
# max zoome

TILEMILL_BIN=/Applications/TileMill.app/Contents/Resources

case $($TILEMILL_BIN/node -v) in
  v0\.4\.[0-9]*) nice -n19 $TILEMILL_BIN/node $TILEMILL_BIN/index.js \
    export $1 $2 --format=mbtiles --log=1 --bbox=$3 --minzoom=$4 --maxzoom=$5;;
  *) echo Currently TileMill requires node 0.4.x. You are using $(node -v) >&2 && exit
esac
