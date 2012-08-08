// interpolates a color ramp given a base color and some other parameters.
// --base   = base color
// --height = max elevation in file
//
// Zac McCormick 9/17/2011

var argv = require('optimist')
    .usage('Generate a color ramp file for usage with gdaldem.\nUsage: $0')
    .demand('b').alias('b', 'base').describe('b', 'Base color (hex string, e.g. #f0dfc7)')
    .demand('h').default('h', 2500).alias('h', 'height').describe('h', 'Max elevation in tif (e.g. 2500)')
    .demand('s').default('s', 100).alias('s', 'steps').describe('s', 'Number of color values (e.g. 100)')
    .demand('min').default('min', 0.5).describe('min', 'Starting ramp value (e.g. 1.0)')
    .demand('max').default('max', 0.0000001).describe('max', 'Ending ramp value (e.g. 0.2)')
    .demand('type').default('type', 'value').describe('type', 'Type of interpolation (value or hue)')
    .demand('file').describe('file', 'Output ramp file')
    .argv;

var fs = require('fs');
var Color = require("color");

var Ramp = {
  generate: function(base, height, steps, start, stop, file) {
    var base_color = Color(base);
    var output_colors = [];
    var step  = (stop - start) / steps;
    //console.log(step + ' ' + steps + ' ' + start + ' ' + stop + ' ' + file);

    var startValue = height > 0 ? height : 0;

    for (var i = start, j = startValue; stop > start ? i <= stop : i >= stop; i += step, j -= height/steps) {
      var ramped = Color(base_color.hexString());

      if (argv.type == 'hue') {
        ramped = ramped.rotate(i);
      } else {
        ramped = stop > start ? ramped.lighten(i) : ramped.darken(i);
      }
      //ramped = ramped.rotate(i);

      var map = [parseInt(j) * (height > 0 ? 1 : -1), ramped.rgbArray()[0], ramped.rgbArray()[1], ramped.rgbArray()[2]];

      output_colors.push(map);
    }

    var lines = [];

    output_colors.forEach(function(c) {
      c.push(255);
      lines.push(c.join(' '));
    });

    fs.writeFileSync(file, lines.join('\n'), 'utf8');

    console.log(lines.join('\n'));
  }
};

Ramp.generate(argv.b, parseFloat(argv.h), parseFloat(argv.s), parseFloat(argv.min), parseFloat(argv.max), argv.file, argv.type);
