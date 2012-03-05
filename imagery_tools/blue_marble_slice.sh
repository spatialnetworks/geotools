# slice Blue Marble imagery into four smaller quadrants, to fit in TileMill

gdalwarp -te -180 0 0 90 bluemarble.tif bluemarble-0.tif
gdalwarp -te 	0 0 180 90 bluemarble.tif bluemarble-1.tif
gdalwarp -te -180 -90 0 0 bluemarble.tif bluemarble-2.tif
gdalwarp -te 0 -90 180 0 bluemarble.tif bluemarble-3.tif
