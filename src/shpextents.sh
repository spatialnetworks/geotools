#!/bin/bash
# Get the extents of a shapefile
# Usage:
# ./shpextents.sh FILE.shp

display_help() {
  cat <<-help
  Usage: shpextents [filename]
help
  exit 0
}

get_extents() {
  local SHPFILE=$1
  local BASE=`basename $SHPFILE .shp`
  local EXTENT=`ogrinfo -so $SHPFILE $BASE | grep Extent \
  | sed 's/Extent: //g' | sed 's/(//g' | sed 's/)//g' \
  | sed 's/ - /, /g'`
  EXTENT=`echo $EXTENT | awk -F ',' '{print $1 " " $4 " " $3 " " $2}'`
  echo $EXTENT
}


if test $# -eq 0; then
  display_help
else
  while test $# -ne 0; do
    case $1 in
      *) get_extents $@; exit ;;
    esac
    shift
  done
fi


