# Shell tools for PostGIS
# Add to your shell profile -- ~/.bash_profile, ~/.bashrc, ~/.zshrc, etc.

# Create a PostGIS-enabled database locally
# usage: creategisdb dbname

function creategisdb() {
	createdb --username=postgres $1
	createlang --username=postgres plpgsql $1
	# Paths to PostGIS SQL files
	psql --username=postgres -d $1 -f ~/Dropbox/tools/postgis/postgis.sql
	psql --username=postgres -d $1 -f ~/Dropbox/tools/postgis/spatial_ref_sys.sql
}

# Uses imposm and an OSM .pbf or .bz2 extract to read, write, and optimize in a new PostGIS database
# usage: imposmimport dbname 
# note: database must be precreated (hopefully with creategisdb)

function imposmimport() {
	imposm --read --write --optimize --deploy-production-tables -d $1 -U postgres 
}
