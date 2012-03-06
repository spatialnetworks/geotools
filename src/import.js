var csv = require('ya-csv');
var sql = require('sqlite3').verbose();
var fs = require('fs');
var db;

require('./priority_queue');
require('./procedure');


MAX_IMPORT_ROWS = 100000;

var queue = new PriorityQueue();
var proc = new Procedure();
var csvFileName = process.argv[2];
var outputDatabaseName = csvFileName.substr(0, csvFileName.length - 4) + '.db';


Points = [];
Clusters = {};

CLUSTER_DEF = {
	 6: 0.008,
	 7: 0.008,
	 8: 0.008,
	 9: 0.008,
	10: 0.008,
	11: 0.500,
	12: 0.050,
	13: 0.008,
	14: 0.0008,
	15: 0.00008,
	16: 0.008,
	17: 0.008,
	18: 0.008,
	19: 0.008,
	20: 0.008
}



function padString(text, length) {
    var str = '' + text;

    while (str.length < length) {
        str = str + ' ';
    }
   
    return str;
}

function replicate(text, times) {
	var rs = '';
	
	while (times > 0) {
		rs += text;
		times--;
	}
	
	return rs;
}


function parseCsv() {
	var rows = [];
	var reader = csv.createCsvFileReader(csvFileName, { columnsFromHeader: true });

	reader.addListener('data', function(data) {
		rows.push(data);
	});

	reader.addListener('end', function(data) {
	    console.log(rows.length.toString() + ' row(s) extracted from file.');

		//continue to next step
		proc.next(rows);
	});
}



function roundPoint(value, increment) {
	return Math.round(value / increment) * increment;
}


function processPoints(rows) {
	var count = 0;

	for (var i = 0; i < rows.length; ++i) {
		if (i >= MAX_IMPORT_ROWS) {
			break;
		}
		
		var row = rows[i];
		var latitude = parseFloat(row.latitude || row.lat);
		var longitude = parseFloat(row.longitude || row.lng || row.long);
		
		//if (i == 1)
			//console.log(latitude + ' ' + longitude);
			
			
		Points.push({latitude: latitude, longitude: longitude});
	}
	
	//console.log(Points.length.toString() + ' point(s) processed from file.');
	//return;
	
	proc.next(Points);
}






function processClustersForZoomLevel(zoomLevel) {
	for (var i = 0; i < Points.length; ++i) {
		var point = Points[i];
		
		var latitude = roundPoint(point.latitude, CLUSTER_DEF[zoomLevel]);
		var longitude = roundPoint(point.longitude, CLUSTER_DEF[zoomLevel]);
		
		if (!Clusters[zoomLevel]) { 
			Clusters[zoomLevel] = { count: 0 };
		}
		
		if (!Clusters[zoomLevel][latitude]) {
			Clusters[zoomLevel][latitude] = {};
		}
		
		if (!Clusters[zoomLevel][latitude][longitude]) {
			Clusters[zoomLevel].count++;
			Clusters[zoomLevel][latitude][longitude] = { points:[] };
		}
	
		Clusters[zoomLevel][latitude][longitude].points.push(point);
	}
	
	console.log(Clusters[zoomLevel].count.toString() + ' cluster(s) processed for zoom level ' + zoomLevel + ' with a ' + CLUSTER_DEF[zoomLevel] + ' degree radius.');
}




function processClusters() {
	//processClustersForZoomLevel(11);
	//processClustersForZoomLevel(12);
	//processClustersForZoomLevel(13);
	//processClustersForZoomLevel(14);
	//processClustersForZoomLevel(15);
	
	console.log('Processing OPTICS Clusters...');
	
	var clusterMap = optics(Points, 0.05, 1);
	
	//extractClusters(clusterMap, 0.045);
	extractClusters(clusterMap, 0.0);
	computeClusterCentroids(RealClusters);
	
	//console.log(RealClusters);



	proc.next();
}





/*
ExtractDBSCAN(OrderedPoint s, ei, MinPts):
2 clusterId = NOISE
3 for each obj in OrderedPoints:
4  if obj.reachability > ei:
5    if obj.coreDistance <= ei:
6      clusterId = nextId(clusterId)
7      obj.clusterId = clusterId
8    else:
9     obj.clusterId = NOISE
10 else:
11 obj.clusterId = clusterId
*/

RealClusters = [];

NoiseCluster = { points:[] };

function extractClusters(points, epsilon) {
	var cluster = { points:[] };
	RealClusters.push(cluster);
	
	console.log(points.length + ' point(s) in ordered list')
	for (var i = 0; i < points.length; ++i) {
		var point = points[i];
		
		console.log(point.reachabilityDistance + ' ' + point.maxDistance);
		
		if (point.reachabilityDistance != undefined && point.reachabilityDistance > epsilon) {
			if (point.maxDistance != undefined && point.maxDistance <= epsilon) {
				//create a new cluster
				point.cluster = cluster = { points:[] };
				RealClusters.push(cluster);
			} else {
				//there's no points within epsilon
				point.cluster = cluster = { points:[] };
				RealClusters.push(cluster);
			}
		} else {
			//point is in the current cluster
			point.cluster = cluster;
		}
		
		cluster.points.push(point);
	}
	
	console.log('Extracted ' + RealClusters.length + ' cluster(s) from ' + points.length + ' point(s)');
}



function computeClusterCentroids(clusters) {
	for (var i = 0; i < clusters.length; ++i) {
		var cluster = clusters[i];
		
		var sumLat = 0;
		var sumLong = 0;
		
		for (var j = 0; j < cluster.points.length; ++j) {
			sumLat += cluster.points[j].latitude;
			sumLong += cluster.points[j].longitude;
		}
		
		if (cluster.points.length > 0) {
			cluster.latitude = sumLat / cluster.points.length;
			cluster.longitude = sumLong / cluster.points.length;
		}
	}
}


















/*
function insertClusterDetails(cluster, points) {
	var clusterDetStatement = db.prepare("INSERT INTO cluster_det VALUES (?, ?)");
	
	for (clusterPointIndex = 0; clusterPointIndex < points.length; ++clusterPointIndex) {
		clusterDetStatement.run([cluster.rowId, points[clusterPointIndex].rowId]);
	}
	
	//clusterDetStatement.finalize(finishDatabase);
}
*/






function deleteDatabase() {
	console.log('Deleting database ' + outputDatabaseName);
	
	try {
		fs.unlink(outputDatabaseName, function(err) { proc.next(); });
	} catch(ex) { proc.next(); }
	
	db = new sql.Database(outputDatabaseName, createTables);
		
	//console.log('Successfully imported ' + rows.length + ' point(s).')
}


function createDatabase() {
	console.log('Creating database ' + outputDatabaseName);

	db = new sql.Database(outputDatabaseName, function(err) { proc.next(); } );
}



function createTables() {
	db.run("CREATE TABLE point (latitude REAL, longitude REAL, intensity REAL);", function() {
		db.run("CREATE TABLE cluster (zoom INT, latitude REAL, longitude REAL, intensity REAL, count INT);", function() {
			db.run("CREATE TABLE cluster_det (cluster_id INT, point_id INT);", function(err) { proc.next(); });
		});
	});
}



function beginTransaction() {
	console.log('Beginning transaction...');
	
    db.serialize(function() {
        // Set the synchronous flag to OFF for (much) faster inserts.
        // See http://www.sqlite.org/pragma.html#pragma_synchronous
        db.run('PRAGMA synchronous = 0');
		db.run('BEGIN;', function(err) { proc.next(); });
    });
}

function insertPoints() {
	console.log('Inserting ' + Points.length + ' point(s)...');
	
	var stmt = db.prepare("INSERT INTO point VALUES (?, ?, ?)");

	for (var i = 0; i < Points.length; ++i) {
		var point = Points[i];
		
		stmt.run([point.latitude, point.longitude, point.intensity || 1.0], function(p) {
			p.rowId = this.lastID;
		}.bind(stmt, point));
	}
	
	stmt.finalize(function(err) { proc.next(); });
}



ClusterDetCount = 0;

function insertClusters() {
	console.log('Processing clusters...');
	
	var clusterStatement = db.prepare("INSERT INTO cluster VALUES (?, ?, ?, ?, ?)");
	var clusterCount =  0;
	
	var zoomLevel = 12;
	
	//for (var zoomLevel in Clusters) {
		console.log('Processing clusters for zoom level ' + zoomLevel + '...');
		
		for (var clusterIndex = 0; clusterIndex < RealClusters.length; ++clusterIndex) {
 		//for (var clusterLat in Clusters[zoomLevel]) {
		//	for (var clusterLong in Clusters[zoomLevel][clusterLat]) {
			var cluster = RealClusters[clusterIndex];
			var clusterLat = cluster.latitude;
			var clusterLong = cluster.longitude;
			
				clusterCount++;
				
				//var clusterObject = Clusters[zoomLevel][clusterLat][clusterLong];

				//console.log('Cluster contains ' + cluster.points.length + ' point(s)');
				
				clusterStatement.run([zoomLevel, clusterLat, clusterLong, cluster.points.length, cluster.points.length], function(cluster) {
					cluster.rowId = this.lastID;
					
					var clusterDetStatement = db.prepare("INSERT INTO cluster_det VALUES (?, ?)");
					
					//console.log('Inserting ' + cluster.points.length + ' detail record(s)');
					
					for (clusterPointIndex = 0; clusterPointIndex < cluster.points.length; ++clusterPointIndex) {
						++ClusterDetCount;
						clusterDetStatement.run([cluster.rowId, cluster.points[clusterPointIndex].rowId]);
					}
					
					clusterDetStatement.finalize();
				}.bind(clusterStatement, cluster));
			}
		//}
	//}
	
	clusterStatement.finalize(function(err) { proc.next(); });
}



function commitTransaction() {
	console.log('Committing transaction...');
	db.run('COMMIT;', function(err) { proc.next(); });
}

function closeDatabase() {
	console.log('Closing database...');
	db.close(function(err) { proc.next(); });
}






function success() {
	console.log('Success. (' + ClusterDetCount + ' detail record(s) created).');

	//for (var i = 0; i < clusterMap.length; ++i) {
	//	console.log(clusterMap[i].maxDistance);
	//}
	
}
















/*
OPTICS(DB, eps, MinPts)
   for each point p of DB
      p.reachability-distance = UNDEFINED
   for each unprocessed point p of DB
      N = getNeighbors(p, eps)
      mark p as processed
      output p to the ordered list
      Seeds = empty priority queue
      if (core-distance(p, eps, Minpts) != UNDEFINED)
         update(N, p, Seeds, eps, Minpts)
         for each next q in Seeds
            N' = getNeighbors(q, eps)
            mark q as processed
            output q to the ordered list
            if (core-distance(q, eps, Minpts) != UNDEFINED)

*/


function distance(a, b) {
    var lat1 = a.latitude;
    var lon1 = a.longitude;
    var lat2 = b.latitude;
    var lon2 = b.longitude;
    var lat1rad = (lat1 * 0.01745327);
    var lat2rad = (lat2 * 0.01745327);

    return Math.abs(Math.acos(Math.sin(lat1rad) * Math.sin(lat2rad) + Math.cos(lat1rad) * Math.cos(lat2rad) * Math.cos((lon2 * 0.01745327) - (lon1 * 0.01745327))) * 6378.1);
}

function coreDistance(point, epsilon, minPoints) {
	var maxDistance = 0;
	
	if (point.computedCoreDistance) {
		return point.maxDistance;
	}
	
	if (point.neighbors && point.neighbors.length >= minPoints) {
		for (var i = 0; i < point.neighbors.length; ++i) {
			var p = point.neighbors[i];
			maxDistance = Math.max(maxDistance, distance(p, point));
		}
		
		point.maxDistance = maxDistance;
		point.computedCoreDistance = true;
		
		return point.maxDistance;
	} else {
		return undefined;
	}
}

function getNeighbors(points, p, epsilon) {
	var results = [];
	
	for (var i = 0; i < points.length; ++i) {
		var point = points[i];
		
		if (point != p && distance(p, point) < epsilon) {
			results.push(point);
		}
	}
	
	return results;
}

function optics(points, epsilon, minPoints) {
	var orderedList = [];
	
	for (var i = 0; i < points.length; ++i) {
		var point = points[i];
		point.reachabilityDistance = null;
		point.isProcessed = false;
	}
	
	//console.log('\nBEGIN');
	//console.log('0 / ' + points.length);
	
	process.stdout.write('0 / ' + points.length + ' points processed');
	
	for (var i = 0; i < points.length; ++i) {
		process.stdout.write('\r' + (i + 1).toString() + ' / ' + points.length + ' points processed');
		
		var point = points[i];
		//console.log('Looking for neighbors ' + epsilon + ' away from ' + point + '.');
		point.neighbors = getNeighbors(points, point, epsilon);
		point.isProcessed = true;
		orderedList.push(point);
		
		//console.log(point);
		
		var seeds = new PriorityQueue();
		
		if (coreDistance(point, epsilon, minPoints) != undefined) {
			clusterUpdate(point, seeds, epsilon, minPoints);
			
			for (var queueCount = 0; queueCount < seeds.length; ++queueCount) {
				var q = seeds.pop();
				
				var np = getNeighbors(points, q, epsilon);
				
				q.isProcessed = true;
				
				orderedList.push(q);
				
				if (coreDistance(q, epsilon, minPoints) != undefined) {
					clusterUpdate(q, seeds, epsilon, minPoints);
				}
			}
		}
	}
	
	console.log('');
	
	return orderedList;
}






/*
update(N, p, Seeds, eps, Minpts)
   coredist = core-distance(p, eps, MinPts)
   for each o in N
      if (o is not processed)
         new-reach-dist = max(coredist, dist(p,o))
         if (o.reachability-distance == UNDEFINED) // o is not in Seeds
             o.reachability-distance = new-reach-dist
             Seeds.insert(o, new-reach-dist)
         else               // o in Seeds, check for improvement
             if (new-reach-dist < o.reachability-distance)
                o.reachability-distance = new-reach-dist
                Seeds.move-up(o, new-reach-dist)
*/

function clusterUpdate(point, seeds, epsilon, minPoints) {
	var cd = coreDistance(point, epsilon, minPoints);
	
	for (var i = 0; i < point.neighbors.length; ++i) {
		var o = point.neighbors[i];
	//for (var o in point.neighbors) {
		if (!o.isProcessed) {
			var newReachabilityDistance = Math.max(cd, distance(point, o))
			
			if (o.reachabilityDistance == undefined) {
				o.reachabilityDistance = newReachabilityDistance;
				seeds.push(o, newReachabilityDistance);
			} else {
				if (newReachabilityDistance < o.reachabilityDistance) {
					o.reachabilityDistance = newReachabilityDistance;
					seeds.move(o, newReachabilityDistance);
				}
			}
		}
	}
}











var operations = 


proc.steps = [
	parseCsv,
	processPoints,
	processClusters,
	deleteDatabase,
	createDatabase,
	createTables,
	beginTransaction,
	insertPoints,
	insertClusters,
	commitTransaction,
	closeDatabase,
	success
];

proc.next();


