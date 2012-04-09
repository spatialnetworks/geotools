# mdb2pgsql MDBFILE PG_DBNAME GEOM_NAME

function mdb2pgsql() {
	./Users/coleman/local/bin/ogr2ogr -f "PostgreSQL" -t_srs EPSG:4326 -s_srs EPSG:32642 PG:"host=localhost dbname=$2 user=postgres" $1 GEOMETRY_NAME=$3
}