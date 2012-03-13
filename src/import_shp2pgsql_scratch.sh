#!/bin/bash

shapefile=$1
current_dir=$2
database=$3

directories=`ls -p "$current_dir/" | grep "/" | sed 's/\///'`

for dir in $directories
do
	filepath=$dir/$(basename $shapefile)
	filename=$(basename $shapefile)
	layername=${filename%.*}
	
	pg_tablename=public.${dir}_${layername}
	
	echo Importing $filepath...
	echo Table $pg_tablename
	echo $filepath
	shp2pgsql -c -s 4326 -g geometry -I -W CP1256 $filepath $pg_tablename | psql -d $database
	
	#echo Shapefile $filepath imported.
done