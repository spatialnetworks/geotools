var geocoder = require('geocoder');
var fs = require('fs');

fs.appendFileSync = function(path, data, encoding) {
  var fd = fs.openSync(path, 'a');
  if (!Buffer.isBuffer(data)) {
    data = new Buffer('' + data, encoding || 'utf8');
  }
  var written = 0;
  var position = null;
  var length = data.length;

  while (written < length) {
    written += fs.writeSync(fd, data, written, length - written, position);
    position += written;
  }
  fs.closeSync(fd);
};

var data = fs.readFileSync('data.csv').toString();

var lines = data.split('\n');

var columnIndex = 0;
var firstLineParts = lines[0].split(',');

for (var i = 0; i < firstLineParts.length; ++i) {
  if (firstLineParts[i].toLowerCase() == process.argv[2].toLowerCase()) {
    columnIndex = i;
    break;
  }
}

var numProcessed = 0;
var numToProcess = lines.length;
var header = lines[0];

header = header.replace('\r\n', '\n');
header = header.replace('\r', '\n');
header = header.replace('\n', '');

fs.appendFileSync('output.csv', header + ',latitude,longitude\n');

for (var i = 1; i < numToProcess; ++i) {
  var line = lines[i];
  var column = line.split(',')[columnIndex];

  geocoder.geocode(column, function(err, data) {
    var geoData = ',';

    if (err) {
      console.log(err);
    } else if (data && data.results && data.results.length > 0) {
      geoData = data.results[0].geometry.location.lat + ',' + data.results[0].geometry.location.lng;
    } else {
      console.log(data);
    }

    ++numProcessed;

    console.log('Processed line ' + numProcessed + ' : ' + geoData);

    line = line.replace('\r\n', '\n');
    line = line.replace('\r', '\n');
    line = line.replace('\n', '');

    fs.appendFileSync('output.csv', line + ',' + geoData + '\n');
  });
}



