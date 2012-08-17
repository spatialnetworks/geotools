#!/bin/sh

# A simple wrapper for the projection.rb thor script that checks if the
# first arg is a file. If it is, run the show command with the -f switch.

if [ -f "$1" ]; then
  filename="$1"; shift;
  projection show -f "$filename" $@
else
  projection $@
fi
