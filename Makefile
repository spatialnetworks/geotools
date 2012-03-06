
PREFIX ?= ~/local/bin/geotools

SRC_IMAGERY   := blue_marble_bb blue_marble_slice gdalwarp_merc merge project shpextents
SRC_GDALGEM   := colorize hillshade contour
SRC_GRATICULE := graticule
SRC_TILEMILL  := automill multimill tilemill_project optimize

install:
	mkdir -p $(PREFIX)
	
	cp $(foreach script, $(SRC_IMAGERY),   imagery_tools/$(script)) $(PREFIX)
	cp $(foreach script, $(SRC_GDALGEM),   gdaldem/$(script))       $(PREFIX)
	cp $(foreach script, $(SRC_GRATICULE), graticules/$(script))    $(PREFIX)
	cp $(foreach script, $(SRC_TILEMILL),  tilemill/$(script))      $(PREFIX)

	chmod +x $(PREFIX)/*

	@echo "Installed:"

	ls $(PREFIX)

	@echo "Make sure $(PREFIX) is in your PATH"

uninstall:
	rm -rf $(PREFIX)

.PHONY: install uninstall
