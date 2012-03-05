# Convert image from WGS84 to Web Mercator
# gdalwarp_merc.sh inputfile outputfile

gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear $1 $2 
