

output_path = File.join(ARGV[0] || '.', "") 

files = []

Dir.entries(output_path).each do |file|
  files << File.join(output_path, file) if file =~ /\.sid$/
end

gdal_merge = "gdal_merge.py -of GTiff -co TILED=YES -co COMPRESS=JPEG -co PHOTOMETRIC=YCBCR -o /Users/zacmcc/data/pinellas_all.tif #{files.join(' ')}"
system gdal_merge


#gdal_merge.py -of JPEG -o /Users/zacmcc/data/pinellas_all.jpg /Users/zacmcc/data/antarctica_color_part2_geo.tif /Users/zacmcc/data/antarctica_color_part2.tif /Users/zacmcc/data/antarctica_hillshade_3031.tif
