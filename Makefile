
all: lib testlib

lib:
	zip -r src/LevelTools.zip src/haxelib.xml src/org/

clean:
	rm -f src/LevelTools.zip
	rm -rf ./bin/*
	rm -rf ./__chxdoctmp

testlib:
	haxelib test src/LevelTools.zip

docs:
	haxelib run nme build ./application.nmml flash -xml
	chxdoc -o docs \
	--developer=true \
	--installTemplate=true \
	--templateDir=chxdoc-templates/migidoc/ \
	--title='LevelTools API' \
	--subtitle='https://github.com/migimunz/LevelTools' \
	-f flash \
	-f nme \
	-f haxe \
	bin/flash/types.xml
