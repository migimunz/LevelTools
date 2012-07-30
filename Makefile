
all: lib install

lib:
	zip -r src/LevelTools.zip src/haxelib.xml src/org/

clean:
	rm -f src/LevelTools.zip
	rm -rf ./bin/*
	rm -rf ./docs/*
	rm -rf ./__chxdoctmp

install:
	haxelib test src/LevelTools.zip

doc:
	haxelib run nme build ./application.nmml flash -xml
	chxdoc -o docs --developer=true --installTemplate=true --templateDir=chxdoc-templates/migidoc/ bin/flash/types.xml
