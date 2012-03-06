#!/usr/bin/env ruby

# EXPERIMENTAL vector simplification for 
# Zac McCormick

require 'gdal/gdal'
require 'gdal/ogr'
require 'gdal/osr'
require './gis_utils'

class Optimizer
  MAX_ZOOM = 22

  def self.optimize(input_path, output_path, input_projection=nil, output_projection=GisUtils::MERCATOR, extra_params="", max_zoom=MAX_ZOOM)
    base_file_name = File.basename(input_path, File.extname(input_path))
    base_path_name = File.join(output_path, base_file_name)

    (0..0).reverse_each do |zoom|
      command = [
        "ogr2ogr -f SQLite",
        "-overwrite",
        "-progress",
        "-skipfailures",
        zoom > 0 ? "-update" : "",
        "-simplify #{"%4.12f" % (360.0 / (2**zoom))}",
        #zoom > 0 ? "-simplify #{360.0 / 2**(zoom - 1)}" : "",
        #output_projection == GisUtils::MERCATOR ? "-clipsrc #{GisUtils::MERCATOR_BOUNDS}" : "",
        extra_params,
        output_projection ? "-t_srs \"#{output_projection}\"" : "",
        input_projection  ? "-s_srs \"#{input_projection}\"" : "",
        "#{base_path_name}.sqlite",
        "#{input_path}",
        "-dsco SPATIALITE=YES",
        zoom > 0 ? "-nln \"#{base_file_name}_z#{zoom}\"" : "-nln \"#{base_file_name}\""
      ].join(" ")

      puts command
      system command
    end
  end
end

#Optimizer.optimize("~/data/hunger_shapefile/hunger.shp", "~/data/optimized", nil, GisUtils::MERCATOR, "-nlt MULTIPOLYGON")
Optimizer.optimize("~/data/fl_seagrass/fl_seagrass_wgs84.shp", "~/data/optimized", nil, GisUtils::MERCATOR, "-nlt MULTIPOLYGON")


#input_file = ARGV[0]
#puts input_file
#File.expand_path(File.basename(file, File.extname(file))
#to_spatialite = "ogr2ogr -f SQLite 
#ogr2ogr -f SQLite `remove-ext $1`.sqlite $1 -dsco SPATIALITE=YES
