#!/usr/bin/env python

## Configure settings for OSM mapping in TileMill ##
## Reads and replaces settings for project paths  ##
## and PostGIS settings for each layer.           ##

# PostGIS connection setup
host     = ""
port     = "5432"
dbname   = "fulcrum-osm"
user     = "osm"
password = "osm"

# shapefiles required for the style. If you have already downloaded
# these or wish to use different versions, specify their paths here.

# by default will be downloaded first compile (will take ~20 minutes)
processed_p = shoreline_300 = boundaries = tm_world = None

# Use proper processed_p coastline data, from S3
# 325 MB, takes time to download and cache local
# source - http://tile.openstreetmap.org/processed_p.tar.bz2
processed_p = "https://s3.amazonaws.com/sni-geodata/osm/boundary/processed_p.zip"

# Use simplified shoreline_300 data, from S3
# 49 MB, caches locally
# - http://tile.openstreetmap.org/shoreline_300.tar.bz2
shoreline_300 = "https://s3.amazonaws.com/sni-geodata/osm/boundary/shoreline_300.zip"

# - http://mapserver-utils.googlecode.com/svn/trunk/data/boundaries.shp
world = "https://s3.amazonaws.com/sni-geodata/naturalearth/1.4.0/cultural/shoreline_300.zip"

# http://thematicmapping.org/downloads/TM_WORLD_BORDERS-0.3.zip
#tm_world = "/benchmarking/wms/2011/data/vector/osm_base_data/data/TM_WORLD_BORDERS-0.3.shp"

# srid of your postgres tables
srid = 3857

# postgres pool size, must be over # of threads
max_size = 33

# if you have > 2GB mem, turn this on
feat_caching = True

# testing http://trac.mapnik.org/ticket/870
deferred_labels = True

#################################

import json
from sys import path
from os.path import join

# path to .mml project file
mml = join(path[0], 'fulcrum-osm/fulcrum-osm.mml')

with open(mml, 'r') as f:
  newf = json.loads(f.read())
f.closed

with open(mml, 'w') as f:
  for layer in newf["Layer"]:
    layer["properties"] = {}
    if feat_caching:
        layer["properties"]["cache-features"] = "true"
    if deferred_labels:
        layer["properties"]["deferred-labels"] = "true"
    if layer["Datasource"]["type"] == "postgis":
      layer["Datasource"]["host"] = host
      layer["Datasource"]["port"] = port
      layer["Datasource"]["dbname"] = dbname
      layer["Datasource"]["user"] = user
      layer["Datasource"]["password"] = password
      #layer["Datasource"]["extent"] = extent
      layer["Datasource"]["srid"] = srid
      layer["Datasource"]["max_size"] = max_size 
    file_ds = layer["Datasource"].get("file")
    if (file_ds):
        if shoreline_300 and "shoreline_300" in file_ds:
          layer["Datasource"]["file"] = shoreline_300
        elif processed_p and "processed_p" in file_ds:
          layer["Datasource"]["file"] = processed_p
        elif tm_world and "TM_WORLD_BORDERS" in file_ds:
          layer["Datasource"]["file"] = tm_world
        elif boundaries and "boundaries" in file_ds:
          layer["Datasource"]["file"] = boundaries
  f.write(json.dumps(newf, sort_keys=True, indent=2))
f.closed

print 'wrote: ' + mml

