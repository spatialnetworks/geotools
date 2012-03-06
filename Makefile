
PREFIX     ?= ~/local/geotools
BIN_PREFIX ?= $(PREFIX)/bin
LIB_PREFIX ?= $(PREFIX)/lib

BIN_SCRIPTS := $(wildcard src/*)
LIB_SCRIPTS := $(wildcard lib/*)

install:
	mkdir -p $(BIN_PREFIX)
	mkdir -p $(LIB_PREFIX)

	cp $(BIN_SCRIPTS) $(BIN_PREFIX)
	cp $(LIB_SCRIPTS) $(LIB_PREFIX)

	chmod +x $(BIN_PREFIX)/*

	cp package.json $(PREFIX) && cd $(PREFIX) && npm install

	ls $(BIN_PREFIX)

	@echo "Make sure $(BIN_PREFIX) is in your PATH"

uninstall:
	rm -rf $(BIN_PREFIX)
	rm -rf $(LIB_PREFIX)

.PHONY: install uninstall
