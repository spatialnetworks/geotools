#!/bin/bash

left=-180

for i in A B C D
do 
	right=`expr $left + 90`	
	top=90
	for k in 1 2
	do
		bot=`expr $top - 90`
		file=world.200401.3x21600x21600.${i}${k}.png 
		ofile=world.200401.3x21600x21600.${i}${k}.tif 
		if [ -e $ofile ] 
		then  
			echo $ofile exists
		else
			gdal_translate -of GTiff -a_srs EPSG:4326 \
                           -a_ullr $left $top $right $bot $file $ofile
		fi
		top=0
	done
	left=`expr $left + 90`
done
