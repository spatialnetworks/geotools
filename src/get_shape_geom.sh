#!/bin/bash
# Output the geometry type for a shapefile
# Usage:
# get_shape_geom.sh filename

filename=$1
extension=${filename##*.}
basename=${filename%.*}

ogrinfo -so $filename $basename | grep -w Geometry | sed 's/Geometry: //g'