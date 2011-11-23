var fs = require('fs');

var inputFileName = process.argv[2];
var outputFileName = inputFileName.replace('.json', '.geojson');

var data = JSON.parse(fs.readFileSync(inputFileName));

var coordinates = [];

data.locations.forEach(function(item) {
    coordinates.push([
        item.longitude, 
        item.latitude, 
        item.altitude, 
        item.course, 
        item.horizontal_accuracy, 
        item.vertical_accuracy, 
        item.speed
    ]);
});

var geoJSON = { 
    type: 'FeatureCollection',
    features: {
        type: 'Feature',
        properties: { description: data.description },
        geometry: { type: 'Point', coordinates: coordinates }
    }
};

fs.writeFileSync(outputFileName, JSON.stringify(geoJSON, null, '\t'));

console.log('Done ' + outputFileName);


