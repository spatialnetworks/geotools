#!/usr/bin/env ruby

# Usage
# tomerc.rb somefile.shp

input_file = ARGV[0]

ogr_op = [
  'ogr2ogr',
  '-f "ESRI Shapefile"',
  '-t_srs "EPSG:900913"',
  "\"#{File.join(File.dirname(input_file), File.basename(input_file, File.extname(input_file)))}_merc.shp\"",
  "\"#{input_file}\""
].join(' ')

puts ogr_op
system ogr_op
