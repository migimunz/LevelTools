package org.ivar.leveltools;
import haxe.xml.Fast;
import nme.installer.Assets;
import org.flixel.FlxState;
import org.ivar.leveltools.Level;
import org.flixel.FlxG;
/**
 * ...
 * @author Nemanja Stojanovic
 */
private class Tileset
{
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var imagePath:String;
	
	public function new(tileWidth:Int, tileHeight:Int, imagePath:String)
	{
		this.tileWidth 	= tileWidth;
		this.tileHeight = tileHeight;
		this.imagePath 	= imagePath;
	}
}
 
class TiledLevel extends Level
{
	private var tilesets:Hash<Tileset>;
	private var defaultTileset:Tileset;
	
	public function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback) 
	{
		super(assetsPath, tilemapAddCallback, objectAddCallback);
		tilesets = new Hash<Tileset>();
	}
	
	private function parseLevel(addToScene:Bool, map:Fast):Void
	{
		for (node in map.nodes.tileset)
			parseTileset(node);
		
		for (node in map.nodes.layer)
			parseLayer(node);
			
		if (addToScene)
			FlxG.getState().add(masterLayer);
	}
	
	private function parseLayer(layerNode:Fast):Void
	{
		var name:String 			= layerNode.att.name;
		var width:Int 				= Std.parseInt(layerNode.att.width);
		var height:Int 				= Std.parseInt(layerNode.att.height);
		var csv:String 				= sanitizeCSV(layerNode.node.data.innerData);
		
		var properties:Properties	= new Properties(layerNode);
		if (layerNode.has.visible)
			properties.set("visible", layerNode.att.visible);
			
		var tilesetName:String = properties.get("tileset");
		var tileset:Tileset;
		if (tilesetName != null && tilesets.exists(tilesetName))
			tileset = tilesets.get(tilesetName);
		else
			tileset = defaultTileset;
		addTilemap(name, 
			width, height,
			tileset.tileWidth, tileset.tileHeight,
			csv, tileset.imagePath, properties);
	}
	
	private function parseTileset(tilesetNode:Fast):Void
	{
		var name:String 			= tilesetNode.att.name;
		var tileWidth:Int 			= Std.parseInt(tilesetNode.att.tilewidth);
		var tileHeight:Int 			= Std.parseInt(tilesetNode.att.tileheight);
		var imageNode:Fast			= tilesetNode.node.image;
		var imagePath:String 		= imageNode.att.source;
		var properties:Properties	= new Properties(tilesetNode);
		
		if (properties.exists("path"))
			imagePath = properties.get("path");
		addTileset(name, tileWidth, tileHeight, imagePath);
	}
	
	private function sanitizeCSV(csv:String):String
	{
		csv = StringTools.replace(StringTools.trim(csv), ",\n", "\n");
		var newCsv:StringBuf = new StringBuf();
		var rows:Array<String> = csv.split("\n");
		
		for (yi in 0 ... rows.length)
		{
			if (yi > 0)
				newCsv.add("\n");
			var values:Array<String> = rows[yi].split(",");
			for (xi in 0 ... values.length)
			{
				var nval:Int = Std.parseInt(values[xi]) - 1;
				nval = nval < 0 ? 0 : nval;
				if(xi > 0)
					newCsv.add(",");
				newCsv.add(nval);
			}
		}
		return newCsv.toString();
	}
	
	
	private function addTileset(name:String, tileWidth:Int, tileHeight:Int, imagePath:String):Void
	{
		var tileset:Tileset = new Tileset(tileWidth, tileHeight, imagePath);
		tilesets.set(name, tileset);
		if (defaultTileset == null)
			defaultTileset = tileset;
	}

	private function addTilemap(name:String, width:Int, height:Int,
		tileWidth:Int, tileHeight:Int,
		csv:String, tilesetPath:String, properties:Properties):Void
	{
		var map:FlxTilemap = new FlxTilemap();
		tilemaps.set(name, map);
			
		map.loadMap(csv, assetsPath + tilesetPath, 
			tileWidth, tileHeight, 0,
			properties.getInt("startindex", 0),
			properties.getInt("drawindex", 1),
			properties.getInt("collideindex", 1));
		map.x = properties.getInt("x");
		map.y = properties.getInt("y");
		map.scrollFactor.x = properties.getFloat("scrollx", 1.0);
		map.scrollFactor.y = properties.getFloat("scrolly", 1.0);
		
		map.visible = properties.getBool("visible", true);
		map.setSolid(properties.getBool("solid", true));
		
		masterLayer.add(map);
	}
	
	private function getTileset(name:String):Tileset
	{
		return tilesets.get(name);
	}

	public static function loadLevel(xmlString:String,
		?assetsPath:String = "",
		?addToScene:Bool = true,
		?tilemapAddCallback:TilemapAddCallback = null,
		?objectAddCallback:ObjectAddCallback = null):TiledLevel
	{
		var parsedXml:Xml = Xml.parse(xmlString);
		var fastXml:Fast = new Fast(parsedXml.firstElement());
		
		var level:TiledLevel = new TiledLevel(assetsPath, tilemapAddCallback, objectAddCallback);
		level.parseLevel(addToScene, fastXml);
		return level;
	}
}