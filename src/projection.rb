#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'json'
require 'cgi'
require 'colorize'
require 'dbf'

begin
  require 'rchardet19'
rescue LoadError
  require 'rchardet'
end

class Pj < Thor
  desc "show", "Show the projection of the file"
  method_option :file,    :aliases => "-f", :desc => "Input file", :required => true
  method_option :layer,   :aliases => '-l', :desc => "Input file layer (defaults to first layer if not supplied)"
  method_option :top,     :aliases => '-t', :desc => "Top (first) result only", :default => false
  method_option :verbose, :aliases => '-v', :desc => "Verbose output", :default => false
  method_option :quiet,   :aliases => '-q', :desc => "Quiet output (only output EPSG code, for use in piped commands)", :default => false
  def show
    raise "Input file doesn't exist" unless options[:file] && File.exist?(options[:file])

    layer_name = options[:layer] || `ogrinfo -so -q #{options[:file]} | cut -d ' ' -f 2`.split('\n').first.strip

    if %w(.sid .tif).include?(File.extname(options[:file]))
      proj_wkt = `gdalinfo #{options[:file]} | sed '1,/Coordinate System is:/d' | sed '/Origin =/,$d'` rescue nil
    else
      proj_wkt = `ogrinfo -so #{options[:file]} #{layer_name} | sed '1,/Layer SRS WKT:/d'` rescue nil
    end

    puts "Requesting http://prj2epsg.org/search.json?exact=false&terms=#{CGI.escape(proj_wkt)}" if options[:verbose] and !options[:quiet]

    hits = JSON.parse(`curl -s http://prj2epsg.org/search.json?terms=#{CGI.escape(proj_wkt)}`)

    puts "Got back #{hits['codes'].count} result(s)" if options[:verbose] and !options[:quiet]

    hits = options[:top] ? [hits['codes'].first] : hits['codes']

    if File.extname(options[:file]) == '.shp'
      text_content = ''
      DBF::Table.new(options[:file].gsub(/shp/, 'dbf')).take(100).each do |record|
        columns = record.instance_variable_get("@columns").select {|c| c.type == 'C'}
        columns.each do |c|
          text_content += record.attributes[c.name] || ''
        end
      end
      encoding = CharDet.detect(text_content) unless text_content.empty?
    elsif File.extname(options[:file]) == '.csv'
      encoding = CharDet.detect(File.read(options[:file]))
    end

    hits.each do |hit|
      if options[:quiet]
        puts hit['code']
      else
        puts "#{'Name'.green}\t : #{hit['name']}"
        details = JSON.parse(`curl -s #{hit['url']}`)
        details.delete('wkt') unless options[:verbose]
        details.each {|k,v| puts "#{k.capitalize.dup.green}\t : #{v}" }
        proj4 = `curl -s http://spatialreference.org/ref/epsg/#{hit['code']}/proj4/`
        puts "#{'Proj4'.green}\t : #{proj4}"
        puts "#{'Encoding'.green} : #{encoding.encoding}, #{encoding.confidence * 100}% confident" if encoding
        puts "#{'Info'.green}\t : #{hit['url'].gsub(/json/, 'html')}, http://spatialreference.org/ref/epsg/#{hit['code']}/"
      end
    end
  end
end


Pj.start
