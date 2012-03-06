#/usr/bin/env ruby
# MultiMill - Automates TileMill exports
# Usage: ruby multimill --map=cairo

require 'rubygems'
require 'json'
require 'optparse'
require 'tilemill_project'

OUTPUT_PATH = "~/Downloads"

class MultiMill
	def self.make_db_name(map)
		map.gsub(" ", "_").downcase
	end

	def self.export(map, output_dir)
		file = File.new("maps.json", "r")

		cities = JSON.parse(file.read)

		file.close

		cities.each do |city|
			if city['slug'] == map
				start_export(city, output_dir)
			end
		end
	end

	def self.start_export(export_def, output_dir)
		slug = export_def['slug']
		bounds = export_def['bounds'].join(',')

		#puts "./automill.sh #{slug} #{File.join(OUTPUT_PATH, slug)} \"#{bounds}\" #{export_def['minzoom']} #{export_def['maxzoom']}"

		puts "Exporting project '#{slug}' from TileMill to #{File.join(output_dir, slug)}.mbtiles with bounds \"#{bounds}\" usingc zoom levels #{export_def['minzoom']
}-#{export_def['maxzoom']}"

		system("./automill.sh #{slug} #{File.join(output_dir, slug)}.mbtiles \"#{bounds}\" #{export_def['minzoom']
} #{export_def['maxzoom']}")
	end
end



options = {}
 
optparse = OptionParser.new do |opts|
	opts.banner = "Usage: multimill.rb --map=<name>"

	opts.on('-m', '--map <name>', 'Map definition to export') do |name|
		options[:name] = name
	end

	opts.on('-o', '--outputdir <dir>', 'MBTiles Output directory') do |output_dir|
		options[:output_dir] = output_dir
	end

	opts.on('-h', '--help', 'Display this screen') do
		puts opts
		exit
	end
end
 
optparse.parse!

#TileMillProject.download_data
#TileMillProject.create_project(options[:name], TileMillProject::POSTGRES_HOST, "osm_#{MultiMill::make_db_name(options[:name])}", TileMillProject::POSTGRES_USER, TileMillProject::POSTGRES_PASSWORD, TileMillProject::TILEMILL_DIR)

MultiMill.export(options[:name], options[:output_dir] || OUTPUT_PATH)
