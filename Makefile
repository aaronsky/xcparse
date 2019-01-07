.PHONY: all clean build test archive install

PREFIX := /usr/local

all: clean build archive

clean:
	swift package clean

build: 
	swift build

archive:
	swift build -c release -Xswiftc -static-stdlib --disable-sandbox

install: archive
	mkdir -p $(PREFIX)/bin
	cp .build/release/xcparse $(PREFIX)/bin/
