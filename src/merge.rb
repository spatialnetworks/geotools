#!/usr/bin/env ruby

output_path = File.join(ARGV[0] || '.', "") 

files = []

Dir.entries(output_path).each do |file|
  if file.to_i < 68778
    files << File.join(output_path, file) if file =~ /\.tif$/
  end
end

gdal_merge = "gdal_merge.py -of GTiff -co TILED=YES -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR -o /Users/zacmcc/data/pinellas_imagery_tif_merged/pinellas_1.tif #{files.join(' ')}"
puts gdal_merge
system gdal_merge


#gdal_merge.py -of JPEG -o /Users/zacmcc/data/pinellas_all.jpg /Users/zacmcc/data/antarctica_color_part2_geo.tif /Users/zacmcc/data/antarctica_color_part2.tif /Users/zacmcc/data/antarctica_hillshade_3031.tif
#
#
#
#/Library/Frameworks/GDAL.framework/Programs/gdalwarp -s_srs "+proj=tmerc +lat_0=24.33333333333333 +lon_0=-82 +k=0.999941177 +x_0=200000.0001016002 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=us-ft +no_defs" -t_srs EPSG:4326 -of GTiff -co TILED=YES -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR  ~/data/pinellas_imagery_tif_merged/pinellas_1.tif ~/data/pinellas_imagery_tif_merged/pinellas_1_wgs84.tif
