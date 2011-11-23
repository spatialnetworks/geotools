# MultiMill - Automates TileMill exports
# Usage: ruby create_project --name=cairo --db=osm_africa --tilemilldir=/Users/zacmcc/Documents/MapBox

require 'rubygems'
require 'json'
require 'optparse'
require 'tilemill_project'

options = {}
 
optparse = OptionParser.new do |opts|
	opts.banner = "Usage: create_project.rb --name=<name> --db=<dbname> --tilemilldir=/Users/zacmcc/Documents/MapBox"

	opts.on('-n', '--name=<name>', 'new TileMill project name') do |name|
		options[:project_name] = name
	end

	opts.on('-d', '--db=<dbname>', 'Database name' ) do |dbname|
		options[:dbname] = dbname
	end

	opts.on('-s', '--host=<host>', 'PostgreSQL host name' ) do |host|
		options[:host] = dbname
	end

	opts.on('-u', '--user=<username>', 'PostgreSQL username' ) do |user|
		options[:user] = dbname
	end

	opts.on('-p', '--password=<password>', 'PostgreSQL password' ) do |password|
		options[:password] = dbname
	end

	opts.on('-t', '--tilemilldir=<dir>', 'TileMill dir, e.g. /Users/zac/Documents/MapBox' ) do |tilemill_path|
		options[:tilemill_path] = tilemill_path
	end

	opts.on('-h', '--help', 'Display this screen') do
		puts opts
		exit
	end

	options[:dbname]        ||= TileMillProject::POSTGRES_DB
	options[:host]          ||= TileMillProject::POSTGRES_HOST
	options[:user]          ||= TileMillProject::POSTGRES_USER
	options[:password]      ||= TileMillProject::POSTGRES_PASSWORD
	options[:tilemill_path] ||= TileMillProject::TILEMILL_DIR
end
 
optparse.parse!

puts "Creating project '#{options[:project_name]}' using database '#{options[:dbname]}'"

TileMillProject.download_data(options[:tilemill_path])
TileMillProject.create_project(options[:project_name], options[:host], options[:dbname], options[:user], options[:password], options[:tilemill_path])

