#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'sqlite3'
require 'rmagick'
require 'fileutils'

class Mb < Thor
  desc "composite", "composite an MBTiles file with another one"
  method_option :base,    :aliases => "-b", :desc => "MBTiles to use as the base layer", :required => true
  method_option :overlay, :aliases => "-v", :desc => "MBTiles to composite over the base layer", :required => true
  method_option :output,  :aliases => "-o", :desc => "Output MBTiles file name", :required => true
  def composite
    raise "Base MBTiles file doesn't exist" unless options[:base] && File.exist?(options[:base])
    raise "Overlay MBTiles file doesn't exist" unless options[:overlay] && File.exist?(options[:overlay])

    File.delete(options[:output]) if File.exist?(options[:output])
    FileUtils.cp(options[:base], options[:output])

    basemap_db = SQLite3::Database.new(options[:base])
    overlay_db = SQLite3::Database.new(options[:overlay])
    output_db  = SQLite3::Database.new(options[:output])

    output_db.busy_timeout(100)

    basemap_db.execute("select * from map m inner join images i on m.tile_id=i.tile_id order by zoom_level, tile_column, tile_row") do |row|
      result = Magick::Image::from_blob(row[5]).first

      overlay_db.execute("select * from tiles where zoom_level = #{row[0]} and tile_column = #{row[1]} and tile_row = #{row[2]}") do |overlay_row|
        overlay_img = Magick::Image::from_blob(overlay_row[3]).first
        result = result.composite(overlay_img, Magick::CenterGravity, Magick::OverCompositeOp)
      end

      output_db.execute("update images set tile_data = ? where tile_id = ?",
        SQLite3::Blob.new(result.to_blob), row[3])
    end
  end
end

Mb.start
