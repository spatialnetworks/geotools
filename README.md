# SNI Geotools
Scripts to help with various GIS tasks. See the documentation at the top each script for usage instructions.

## Installation:

    make install

## Uninstallation:

    make uninstall

## Notes
To easily access all of the scripts from the command line, add `~/local/geotools/bin` to your `$PATH`.
This can be done by adding the following line to your shell profile (e.g. `~/.bash_profile`)

    export PATH=~/local/bin/geotools:$PATH

## Hacking
Directly executable scripts go in the `src` directory, any indirectly referenced code goes in `lib` (e.g. ruby/python classes)

It's important that `package.json` is maintained when adding any dependencies for nodejs scripts. Deployment will copy everything
in `src` to the prefix `bin` and invoke `npm install`. To hack on node scripts in the repo, run `npm install` to install the dependencies.
