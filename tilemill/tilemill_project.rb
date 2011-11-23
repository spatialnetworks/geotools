require 'rubygems'
require 'json'
require 'optparse'

class TileMillProject
	TILEMILL_DIR = "/Users/zacmcc/Documents/MapBox"
	TILEMILL_PROJECT = "fulcrum-osm"
	POSTGRES_HOST = "localhost"
	POSTGRES_PORT = "5432"
	POSTGRES_USER = "postgres"
	POSTGRES_PASSWORD = "postgres"
	POSTGRES_DB = "osm"

	WGS84 = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over"
	MAX_SIZE = 32

	PROCESSED_P = "https://s3.amazonaws.com/sni-geodata/osm/boundary/processed_p.zip"
	SHORELINE_300 = "http://tilemill-data.s3.amazonaws.com/osm/shoreline_300.zip"
	SHORELINE_300_SIMPLE = "http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.3.0/cultural/10m-admin-0-countries.zip"

	def self.slugify(name)
		name.gsub(" ", "-").downcase
	end

	def self.create_project(new_project_name, host, dbname, user, password, tilemill_path)
		tilemill_path = tilemill_path || TILEMILL_DIR
		project_path = File.join(tilemill_path, "project", TILEMILL_PROJECT)
		new_project_dir = File.join(tilemill_path, "project", slugify(new_project_name))
		new_project_mml = File.join(new_project_dir, "#{slugify(new_project_name)}.mml")

		system("cp -R #{project_path} #{new_project_dir}")
		system("mv #{File.join(new_project_dir, "fulcrum-osm.mml")} #{new_project_mml}")
		
		file = File.open(new_project_mml, "rb")

		project_def = JSON.parse(file.read)

		file.close

		modify_project(project_def, new_project_name, host || POSTGRES_HOST, POSTGRES_PORT, dbname, user || POSTGRES_USER, password || POSTGRES_PASSWORD, WGS84, MAX_SIZE, tilemill_path)

		File.open(new_project_mml, 'w') { |f| f.write(JSON.pretty_generate(project_def)) }
	end


	def self.modify_project(project_def, name, host, port, dbname, user, password, srs, max_size, tilemill_path)
		project_def['name'] = name
		project_def['Layer'].each do |layer|
			if layer['Datasource']['type'] == 'postgis'
				layer['Datasource']['host']     = host
				layer['Datasource']['port']     = port
				layer['Datasource']['dbname']   = dbname
				layer['Datasource']['user']     = user
				layer['Datasource']['password'] = password
				layer['Datasource']['srs']      = srs
				#layer['Datasource']['max_size'] = max_size
			end

			if layer['Datasource'].has_key?('file')
				file_name = layer['Datasource']['file']
				layer['Datasource']['file'] = File.join(tilemill_path, "data", "shoreline_300.zip") if file_name.include? "shoreline_300"
				layer['Datasource']['file'] = File.join(tilemill_path, "data", "world_simple.zip") if file_name.include? "world_simple"
				layer['Datasource']['file'] = File.join(tilemill_path, "data", "processed_p.zip") if file_name.include? "processed_p"
			end
		end
	end


	def self.download_data(tilemill_path)
		tilemill_path ||= TILEMILL_DIR
		system("curl #{PROCESSED_P} -o #{File.join(tilemill_path, "data", "processed_p.zip")}") if !File.exists?("#{File.join(tilemill_path, "data", "processed_p.zip")}")
		system("curl #{SHORELINE_300_SIMPLE} -o #{File.join(tilemill_path, "data", "world_simple.zip")}") if !File.exists?("#{File.join(tilemill_path, "data", "world_simple.zip")}")
		system("curl #{SHORELINE_300} -o #{File.join(tilemill_path, "data", "shoreline_300.zip")}") if !File.exists?("#{File.join(tilemill_path, "data", "shoreline_300.zip")}")

		#system("unzip #{File.join(TILEMILL_DIR, "data", "processed_p.zip")} -d #{File.join(TILEMILL_DIR, "data")}")
		#system("unzip #{File.join(TILEMILL_DIR, "data", "shoreline_300.zip")} -d #{File.join(TILEMILL_DIR, "data")}")
		#system("unzip #{File.join(TILEMILL_DIR, "data", "world_simple.zip")} -d #{File.join(TILEMILL_DIR, "data")}")
	end

	def self.parse
		counter = 1
		file = File.new("cities.txt", "r")

		while (line = file.gets)
			if counter == 1
				counter = counter + 1
				next
			end

			parts = line.split(',')

			group = parts[0]
			geoname = parts[1]
			top = parts[2]
			left = parts[3]
			bottom = parts[4]
			right = parts[5]
			minzoom = parts[6]
			maxzoom = parts[7]
			slug = parts[8]
			name = parts[9]

			puts group


			system("./mill.sh control-room ~/Downloads/control-room-export.mbtiles \"-179,-80,179,80\" 1 10")

			counter = counter + 1
		end

		file.close

	end

end
