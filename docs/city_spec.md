# City tileset specifications
A `json`-based spec for defining bounding areas, zoom levels, names, etc. for OSM cities.
Inspired by [Migurski's]() city extracts.

## Format

```javascript

{
	
	{
	  
	// Name describing the parent continent of the city.
	"continent": "Africa",
	
	// Name of the city's region.
	"region": "North Africa",
	
	// Country name.
	"country": "Egypt",
	
	// GeoNames ID, for mapping back into the main GeoNames database.
	"geonameid": "360630",
	
	// An array of boundaries in lat / lon.
	// left, bottom, right, top -- in that order
	"bounds": [ 30.897, 29.761, 31.710, 30.564 ],
	
	// Minimum zoom level to include.
	"minzoom": 11,
	
	// Maximum zoom level to include.
	"maxzoom": 16,
	
	// Clean slug name for use in URLs and path names.
	"slug": "cairo",
	
	// City name.
	"cityname": "Cairo"
	}
	
	// Version number.
	"version": "1.0.0"

```