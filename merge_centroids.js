/*
 *
 *  merge_centroids.js
 *  
 *  merges a GeoJSON document containing geometry with a corresponding GeoJSON file containing the geometry's centroids.
 *
 *  usage:
 *    node merge_centroids.js <search_data.js> <geometry_data.sqlite>
 */


var fs = require('fs'),
	sql = require('sqlite3');

var centroidArray = JSON.parse(fs.readFileSync(process.argv[2]));
var centroidIndex = {};
var tableName = process.argv[4];

console.log('Opening database ' + process.argv[3]);


function startDatabase() {
	console.log('Running' + tableName);
	db.run('ALTER TABLE ' + tableName + ' ADD centroid_latitude', function(err) {
		console.log('erererrrr' + err)
		db.run('ALTER TABLE ' + tableName + ' ADD centroid_longitude', function(err) {
			db.run('PRAGMA synchronous = 0');
			console.log('updating centroids');
			updateCentroids();
		});
	});
}


db = new sql.Database(process.argv[3], function(err) {
	startDatabase();
});



//startDatabase();

console.log('Done with database ' + db);



function updateCentroids() {
	centroidArray.features.forEach(function(feature, item) {
		var stmt = db.prepare('UPDATE ' + tableName + ' SET centroid_latitude = ?, centroid_longitude = ? WHERE oid_ = ?');

		stmt.run([feature.coordinates[0], feature.coordinates[1], feature.properties.oid_], function(p) {

		}.bind(stmt, feature));

		stmt.finalize(function(err) { success(); });
	});
}

function success() {
	console.log('success');
}



