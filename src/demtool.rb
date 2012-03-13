#!/usr/bin/env ruby 

require 'rubygems'
require 'thor'

class DemTool < Thor 
  desc "colorize", "color relief" 
  method_option :file, :aliases => "-f", :desc => "File to colorize"
  method_option :ramp, :aliases => "-r", :desc => "Color ramp file", :default => 'ramp.txt'
  def colorize
    output_file = "#{File.join(File.dirname(options[:file]), File.basename(options[:file], File.extname(options[:file])))}_color.tif"

    ['gdaldem', 'color-relief', '-alpha', options[:file], options[:ramp], output_file].join(' ').tap do |op|
      puts op
      system op
    end
  end

  desc "contour", "contour generation"
  method_option :file,      :aliases => "-f", :desc => "File to contour"
  method_option :interval,  :aliases => "-i", :desc => "Elevation interval (e.g. 500.0)"
  method_option :attribute, :aliases => "-a", :desc => "Attribute to use for elevation in the output file", :default => "elev"
  def contour
    output_file = "#{File.join(File.dirname(options[:file]), File.basename(options[:file], File.extname(options[:file])))}_contour.shp"

    ['gdal_contour', "-a #{options[:attribute]}", "-i #{options[:interval]}", options[:file], output_file].join(' ').tap do |op|
      puts op
      system op
    end
  end

  desc "hillshade", "hillshade generation"
  method_option :file,    :aliases => "-f", :desc => "File to create hillshade from"
  method_option :zfactor, :aliases => "-z", :desc => "Vertical exaggeration used to pre-multiply elevation values"
  method_option :scale,   :aliases => "-s", :desc => "Ratio of vertical units to horizontal units, for WGS84, use 111120 for meters and 370400 for feet. For web mercator, use 1", :default => 1
  def hillshade
    output_file = "#{File.join(File.dirname(options[:file]), File.basename(options[:file], File.extname(options[:file])))}_hillshade.tif"

    ['gdaldem', "-z #{options[:zfactor]}", "-s #{options[:scale]}", options[:file], output_file].join(' ').tap do |op|
      puts op
      system op
    end
  end
end

DemTool.start
