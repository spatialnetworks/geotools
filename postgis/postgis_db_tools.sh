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
