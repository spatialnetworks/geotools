# EXPERIMENTAL vector tiling into SpatiaLite and PostGIS
# Zac McCormick

require 'gdal/gdal'
require 'gdal/ogr'
require 'gdal/osr'
require './gis_utils'

class RepTile

	def self.tile_postgis(sqlite_path, postgis_db)
		src_driver = Gdal::Ogr.get_driver_by_name('SQLite')

		src_data = src_driver.open(sqlite_path)

		dest_data = Gdal::Ogr.open("PG: dbname='#{postgis_db}' host='localhost' port='5432' user='postgres' password='postgres'")

		layer_options = ['OVERWRITE=yes']
		
		tile(src_data, dest_data, layer_options)
	end

	def self.tile_sqlite(db_path)
		driver = Gdal::Ogr.get_driver_by_name('SQLite')

		src_data = driver.open(db_path)

		dest_db_path = "#{File.basename(db_path, File.extname(db_path))}_tiled.sqlite"

		driver_options = ['SPATIALITE=yes']
		layer_options  = ['SPATIAL_INDEX=yes']

		File.delete(dest_db_path) if File.exists?(dest_db_path)

		dest_data = driver.create_data_source(dest_db_path, driver_options)

		tile(src_data, dest_data, layer_options)
	end

	def self.tile(src_data, dest_data, layer_options)
		src_layer = src_data.get_layer(0)

		dest_layer = dest_data.create_layer("#{src_layer.get_name}_tiled2", GisUtils.get_WGS84, Gdal::Ogr::WKBPOLYGON, layer_options)

		create_fields_from_layer(src_layer, dest_layer)

		top_left = [34.555, 69.152]
		bottom_right = [34.542, 69.171]

		tiles = GisUtils::bbox2tiles(top_left, bottom_right, 14, 15)

		total_features = 0

		tiles.each do |tile|
			puts "Processing tile #{tile[0]}/#{tile[1]}/#{tile[2]}"

			bbox_parts = [
				"#{tile[3][1]} #{tile[3][0]}",
				"#{tile[4][1]} #{tile[4][0]}",
				"#{tile[5][1]} #{tile[5][0]}",
				"#{tile[6][1]} #{tile[6][0]}",
				"#{tile[3][1]} #{tile[3][0]}"
			]

			bbox_points = bbox_parts.join(', ')
			bbox_wkt = "POLYGON((#{bbox_points}))"

			bbox = Gdal::Ogr::create_geometry_from_wkt(bbox_wkt)
			bbox.assign_spatial_reference(GisUtils.get_WGS84)

			src_layer.set_spatial_filter(bbox)
			src_layer.reset_reading

			feature_index = 0
			feature = nil

			while (feature = src_layer.get_next_feature) != nil
				new_geom = feature.get_geometry_ref.clone

				if new_geom.is_empty
					puts 'Source geometry is empty. Skipping this feature.'
					next
				end

				if !new_geom.is_valid
					puts 'Source geometry isn\'t valid. Skipping this feature.'
					next
				end

				begin
					new_geom = new_geom.intersection(bbox)
				rescue
					puts "TopologyException: #{tile.to_s}"
					next
				end

				if new_geom.is_empty
					puts 'Intersected geometry is empty. Skipping this feature.'
					next
				end

				if !new_geom.is_valid
					puts 'Intersected geometry isn\'t valid. Skipping this feature.'
					next
				end

				tolerance = GisUtils.degrees_per_pixel(tile[0].to_i + 1)

				# GEOSTopologyPreserveSimplify() from GEOS yields MUCH better results (OGR only binds GEOSSimplify)
				# I used ST_SimplifyPreserveTopology() from PostGIS to simplify the geometry after running this script.
				# There's some redundant code below, but that's OK for now.

				output_geom = new_geom #.simplify(tolerance.to_f) 
				output_geom.assign_spatial_reference(GisUtils.get_WGS84)

				if output_geom.is_empty
					puts 'Simplified geometry is empty. Skipping this feature.'
					next
				end

				if !output_geom.is_valid
					puts 'Simplified geometry isn\'t valid. Skipping this feature.'
					next
				end

        new_feature = Gdal::Ogr::Feature.new(dest_layer.get_layer_defn)
        new_feature.set_geometry(output_geom)

				new_feature.set_field('tile_zoom', tile[0].to_i)
				new_feature.set_field('tile_x', tile[1].to_i)
				new_feature.set_field('tile_y', tile[2].to_i)
				
        new_feature.set_fid(total_features)
        
				begin
					dest_layer.create_feature(new_feature)
				rescue RuntimeError
					#I think the few errors from this call are because POLYGON's are being intersected w/ the bbox and resulting in MULTIPOLYGON's
					#Need to add logic to check the resulting geometry type and decompose the MULTIPOLYGON's into multiple regular POLYGON's so
					#they can be added to the same layer. Note: The PostgreSQL driver has MUCH better error messages than the SQLite driver.
					puts "Error creating feature: #{new_feature.to_s} #{$!}"
				end

				#release the ref counted objects, I think this the proper way to do that since there's no explicit Destroy() binding
				new_geom = nil
				output_geom = nil
      	new_feature = nil

				feature_index = feature_index + 1
				total_features = total_features + 1
    	end
		end

		puts total_features
	end


	def self.create_fields_from_layer(src_layer, dest_layer)
		0.upto(src_layer.get_layer_defn.get_field_count - 1) do |field_index|
			field_def = src_layer.get_layer_defn.get_field_defn(field_index)
			dest_layer.create_field(field_def)
		end

		field_list = [
			['tile_x', Gdal::Ogr::OFTINTEGER],
			['tile_y', Gdal::Ogr::OFTINTEGER],
			['tile_zoom', Gdal::Ogr::OFTINTEGER]
		]

		field_list.each do |field_array|
			name = field_array[0]
				
			if field_array.size > 1
				type = field_array[1]
			else
				type = Gdal::Ogr.OFTString
			end
				
			field_definition = Gdal::Ogr::FieldDefn.new(name, type)
			field_definition.set_width(field_array[2].to_int) if field_array.size > 2
			field_definition.set_precision(field_array[3].to_int) if field_array.size > 3

			dest_layer.create_field(field_definition)
		end
	end

	def self.dump_kml(tiles)
		puts '<?xml version="1.0" encoding="UTF-8"?>'
		puts '<kml xmlns="http://www.opengis.net/kml/2.2">'
		puts '<Placemark>'
    puts '<name>Tile Test</name>'
		puts '<MultiGeometry>'

		tiles.each do |tile|
				height = (tile[0] * 100000) + 1000000
				puts '<Polygon>'
      	puts '<extrude>2</extrude>'
      	puts '<altitudeMode>relativeToGround</altitudeMode>'
				puts '<outerBoundaryIs>'
        puts '  <LinearRing>'
        puts '    <coordinates>'
        puts "    	#{tile[3][1]},#{tile[3][0]},#{height}"
        puts "    	#{tile[4][1]},#{tile[4][0]},#{height}"
        puts "    	#{tile[5][1]},#{tile[5][0]},#{height}"
        puts "    	#{tile[6][1]},#{tile[6][0]},#{height}"
        puts "    	#{tile[3][1]},#{tile[3][0]},#{height}"
				puts '    </coordinates>'
        puts '  </LinearRing>'
     		puts '</outerBoundaryIs>'
				puts '</Polygon>'
		end

		puts '</MultiGeometry>'
		puts '</Placemark>'
		puts '</kml>'

	end
end

RepTile::tile_sqlite('buildings.sqlite')
RepTile::tile_postgis('buildings.sqlite', 'reptile')
