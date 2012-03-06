# GisUtils - OGR code taken from fulcrum and added to. This code should be shared.
# Zac McCormick

require 'gdal/gdal'
require 'gdal/ogr'
require 'gdal/osr'

class GisUtils
  WGS84 = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  MERCATOR = "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +lat_ts=0.0 +units=m +nadgrids=@null +wktext +no_defs +over"
  MERCATOR_BOUNDS = "-180.0 -85.05112877980659 180 85.05112877980659"

  def self.sqlite_driver
    Gdal::Ogr.get_driver_by_name('SQLite')
  end

  def self.open_sqlite(path)
    GisUtils.sqlite_driver.open(path)
  end

  def self.create_sqlite(db_path)
    driver_options = ['SPATIALITE=yes']

    File.delete(db_path) if File.exists?(db_path)

    self.sqlite_driver.create_data_source(db_path, ['SPATIALITE=yes'])
  end

  def self.save_shapefile(path, form, documents)
    save_points('ESRI Shapefile', [], path, form, documents)
  end

  def self.save_spatialite(path, form, documents)
    save_points('SQLite', ['SPATIALITE=yes'], path, form, documents)
  end

  def self.save_points(driver_name, driver_options, file_path, form, documents)
    driver = Gdal::Ogr.get_driver_by_name(driver_name)
    
    if File.exists?(file_path)
      if driver_name == 'ESRI Shapefile'
        driver.delete_data_source(file_path)
      else
        File.delete(file_path)
      end
    end

    shape_data = driver.create_data_source(file_path, driver_options)

    srs = get_spatial_ref_from_proj4(WGS84)

    layer = shape_data.create_layer(form.name, srs, Gdal::Ogr::WKBPOINT)
    
    fields = form.get_headers().flatten
    field_def = []

    fields.each do |field|
      field['field_name'] = clean_field_name(driver_name, field['label'])
      field_def.push([field['field_name'], Gdal::Ogr::OFTSTRING])
    end

    create_layer_fields(layer, field_def)
    
    point_index = 0

    documents.each do |doc|
        wkt = "POINT(#{doc.longitude} #{doc.latitude})"

        geometry = Gdal::Ogr::create_geometry_from_wkt(wkt)

        feature = Gdal::Ogr::Feature.new(layer.get_layer_defn())
        feature.set_geometry(geometry)

        fields.each do |field| 
          feature.set_field(field['field_name'], doc.form_values.get(field['key']).to_s)
        end
        
        feature.set_fid(point_index)
        
        layer.create_feature(feature)
 
        geometry = nil
        feature = nil

        point_index = point_index + 1
    end

    layer.sync_to_disk
    
    layer = nil
    shape_data = nil
    driver = nil
  end

  def self.get_WGS84()
    get_spatial_ref_from_proj4(WGS84)
  end

  def self.get_spatial_ref_from_proj4(proj4)
      srs = Gdal::Osr::SpatialReference.new
      srs.import_from_proj4(proj4)
      return srs
  end


  def self.create_layer_fields(layer, field_list)
    ## Each field is a tuple of (name, type, width, precision)

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

      layer.create_field(field_definition)
    end
  end

  def self.clean_field_name(driver, field_name)
    #field_name = field_name.gsub('?', '')
    field_name = field_name.gsub('"', '')

    if driver == 'ESRI Shapefile'
      field_name = field_name[0, 10].rstrip
    end

    if driver == 'SQLite'
      field_name = field_name.downcase
    end

    field_name
  end


  def self.bbox2tiles(top_left, bottom_right, zoom_min, zoom_max)
    tiles = []

    zoom_min.upto(zoom_max) do |zoom|
      top_left_tile = deg2tile(top_left[0], top_left[1], zoom)
      bottom_right_tile = deg2tile(bottom_right[0], bottom_right[1], zoom)
    
      min_x = top_left_tile[0]
      min_y = top_left_tile[1]
      max_x = bottom_right_tile[0]
      max_y = bottom_right_tile[1]

      min_x.upto(max_x) do |x|
        min_y.upto(max_y) do |y|
          tile_left_x = x
          tile_right_x = x + 1
          tile_top_y = y
          tile_bottom_y = y + 1

          tile_left_long  = tile2deg(tile_left_x, tile_top_y, zoom)[1]
          tile_right_long = tile2deg(tile_right_x, tile_top_y, zoom)[1]
          tile_top_lat    = tile2deg(tile_left_x, tile_top_y, zoom)[0]
          tile_bottom_lat = tile2deg(tile_left_x, tile_bottom_y, zoom)[0]

          tiles.push([zoom, x, y,
                     [tile_top_lat, tile_left_long],     #top left
                     [tile_top_lat, tile_right_long],    #top right
                     [tile_bottom_lat, tile_right_long], #bottom right
                     [tile_bottom_lat, tile_left_long]]) #bottom left
        end
      end
    end

    tiles
  end

  def self.tile2deg(xtile, ytile, zoom)
    n = 2.0 ** zoom
    lon_deg = xtile / n * 360.0 - 180.0
    lat_rad = Math.atan(Math.sinh(Math::PI * (1 - 2 * ytile / n)))
    lat_deg = lat_rad * 180.0 / Math::PI
    [lat_deg, lon_deg]
  end

  def self.deg2tile(lat_deg, lon_deg, zoom)
    lat_rad = lat_deg * Math::PI / 180
    n = 2.0 ** zoom
    xtile = ((lon_deg + 180.0) / 360.0 * n).floor
    ytile = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n).floor
    [xtile, ytile]
  end

  #hacky but it'll work for now, just wanted to get these magic values somewhere.
  #taken from http://wiki.openstreetmap.org/wiki/Zoom_levels
  def self.degrees_per_pixel(zoom)
    [
      360 / 256.0,
      180 / 256.0,
      90 / 256.0,
      45 / 256.0,
      22.5 / 256.0,
      11.25 / 256.0,
      5.625 / 256.0,
      2.813 / 256.0,
      1.406 / 256.0,
      0.703 / 256.0,
      0.352 / 256.0,
      0.176 / 256.0,
      0.088 / 256.0,
      0.044 / 256.0,
      0.022 / 256.0,
      0.011 / 256.0,
      0.005 / 256.0,
      0.003 / 256.0,
      0.001 / 256.0
    ][zoom]
  end
end
