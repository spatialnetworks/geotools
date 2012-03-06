#!/usr/bin/env node

/*****

project.js
----------
a node.js tool for reprojecting shapefiles between two SRIDs.

usage:
node ~/Dropbox/dev/maptual_data/project.js ~/Dropbox/shared_coleman/AF 32642 4326

*****/

var fs = require('fs');
var util = require('util'),
    exec = require('child_process').exec;

var directoryName = process.argv[2];
var sourceSRS = process.argv[3];
var transformedSRS = process.argv[4];
var ogr2ogr = process.argv.length >= 6 ? process.argv[5] : 'ogr2ogr';

var outputDirectoryName;

if (directoryName[directoryName.length - 1] != '/') {
	directoryName += '/';
}

outputDirectoryName = directoryName + 'output';

//console.log(outputDirectoryName);

try {
	fs.mkdirSync(outputDirectoryName, 0777);
} catch(ex) {}

var files = fs.readdirSync(directoryName);

files.forEach(function(fileName, index) {
	if (fileName.indexOf('.shp') > -1 && fileName.indexOf('.xml') == -1) {
		//console.log(fileName);
		
		var outputFileName = outputDirectoryName + '/' + fileName;
		var inputFileName = directoryName + fileName;
		
		try {
			fs.unlinkSync(outputFileName);
		} catch (ex) {}
		
		var command = ogr2ogr + ' --config SHAPE_ENCODING UTF-8 -f "ESRI Shapefile" -t_srs EPSG:' + transformedSRS + ' -s_srs EPSG:' + sourceSRS + ' ' + outputFileName + ' ' + inputFileName;
		
		exec(command,
		  function (error, stdout, stderr) {
			if (stdout.length > 0)
		    	console.log('stdout: ' + stdout);
		
			if (stderr.length > 0)
		    	console.log('stderr: ' + stderr);
		    
			if (error !== null) {
				console.log('exec error: ' + error);
			} else {
				console.log('successfully transformed ' + inputFileName + ' to ' + outputFileName);
			}
		});
	}
});
