#!/bin/bash
# Output the geometry type for a shapefile
# Usage:
# get_feature_count_summary.sh filename

filename=$1
extension=${filename##*.}

~/local/bin/ogrinfo -so $filename | grep -w Geometry | sed 's/Geometry: //g'