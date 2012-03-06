#!/usr/bin/env ruby

output_path = File.join(ARGV[0] || '.', "") 

files = []

gdal_path = "/Library/Frameworks/GDAL.framework/Programs/gdal_translate"
dest_path = "/Users/zacmcc/data/pinellas_imagery_tif"
co_params = "-co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR"

Dir.entries(output_path).each do |file|
  if file != ".." && file != "." && file != ".DS_Store"
    gdal_op = "#{gdal_path} #{File.join(output_path, file)} #{co_params} #{File.join(dest_path, file.gsub(/\.sid/, ''))}.tif"
    system gdal_op
    #puts gdal_merge
  end
end




