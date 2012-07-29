
all: lib install

lib:
	zip -r src/LevelTools.zip src/haxelib.xml src/org/

clean:
	rm src/LevelTools.zip
	rm -rf ./bin/*

install:
	haxelib test src/LevelTools.zip