package org.ivar.leveltools;
import haxe.xml.Fast;
import openfl.Assets;
import org.flixel.FlxState;
import org.ivar.leveltools.Level;
import org.flixel.FlxG;
import org.flixel.FlxTilemap;

/**
 * @author Nemanja Stojanovic
 * Represents a tileset, stores tile size and path to the image that contains the tiles.
 * This class is used internally and is invisible outside this module.
 */
private class Tileset
{
	/**
	 * Width of a tile
	 */
	public var tileWidth:Int;

	/**
	 * Height of a tile
	 */
	public var tileHeight:Int;

	/**
	 * Path to the image
	 */
	public var imagePath:String;
	
	/**
	 * Tileset constructor, initializes the object.
	 * @param tileWidth width of a tile in this tileset
 	 * @param tileHeight height of a tile in this tileset
 	 * @param imagePath path to the image
	 */
	public function new(tileWidth:Int, tileHeight:Int, imagePath:String)
	{
		this.tileWidth 	= tileWidth;
		this.tileHeight = tileHeight;
		this.imagePath 	= imagePath;
	}
}

/**
 * @author Nemanja Stojanovic
 * This class deals with loading levels created with Tiled Editor. So far, only loading tilesets
 * is supported and that's a bit experimental too. The problem is that Tiled uses idx 0 when there is no tile
 * and flixel uses 0 to index the first tile, and this doesn't play well with Haxe/Flixel at least.
 * The current solution is to decrement the index of all tiles (except zeros), but hopefully this is just
 * a temporary solution.
 */
class TiledLevel extends Level
{
	/**
	 * A table of tilesets
	 */
	private var tilesets:Map<String, Tileset>;

	/**
	 * The default tileset (will be set to the first tileset loaded)
	 */
	private var defaultTileset:Tileset;
	
	/**
	 * Constructs the object and initalizes members, but doesn't actually parse anything.
	 * @param assetsPath Path to the assets directory from the project's root dir (usually the one containing the .nmml file).
	 * @param tilemapAddCallback a callback that is called every time a tilemap is loaded.
	 * @param objectAddCallback a callback that is called every time an object (sprite) is loaded.
	 * @param linkAddCallback a callback that is called every time a link is loaded.
	 * @return Nothing.
	 */
	public function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback)
	{
		super(assetsPath, tilemapAddCallback, objectAddCallback);
		tilesets = new Map<String, Tileset>();
	}
	
	/**
	 * Parses the level from a loaded xml file.
	 * @param addToScene if true, the level will be added to the current state when loaded
	 * @param map parsed xml that contains the level data
	 * @return Nothing.
	 */
	private function parseLevel(addToScene:Bool, map:Fast):Void
	{
		for (node in map.nodes.tileset)
			parseTileset(node);
		
		for (node in map.nodes.layer)
			parseLayer(node);
			
		if (addToScene)
			FlxG.getState().add(masterLayer);
	}
	
	/**
	 * Loads a single layer and adds it to the master layer.
	 * @param layerNode the node that contains the layer
	 * @return Nothing.
	 */
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
	
	/**
	 * Loads a tileset and stores it into the tilesets table. Used internally.
	 * @param tilesetNode
	 * @return Nothing.
	 */
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
	
	/**
	 * Tiled editor exports csv that contains an extra ',' every line (as well as a few extra newlines),
	 * which flixel refuses to parse.
	 * This method parses the csv, changes the values (decrements all indexes) and generates a csv
	 * string flixel can parse.
	 * @param csv the csv string.
	 * @return parsed csv string.
	 */
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
	
	/**
	 * Adds the parsed tileset to the tileset hashtable.
	 * @param name name of the tileset
	 * @param tileWidth width of a tile in pixels
	 * @param tileHeight height of a tile in pixels
	 * @param imagePath path to the tileset image
	 * @return Nothing.
	 */
	private function addTileset(name:String, tileWidth:Int, tileHeight:Int, imagePath:String):Void
	{
		var tileset:Tileset = new Tileset(tileWidth, tileHeight, imagePath);
		tilesets.set(name, tileset);
		if (defaultTileset == null)
			defaultTileset = tileset;
	}

	/**
	 * Creates a FlxTilemap from parsed xml and adds it to the master layer.
	 * If specified, the tilemapAddCallback is called with the loaded tilemap as argument.
	 * @param group The group of the layer this map belongs to
	 * @param mapNode The node that contains tilemap data
	 * @param layerNode The node that contains layer data
	 * @return Nothing.
	 */
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
		if(tilemapAddCallback != null)
			tilemapAddCallback(map);
	}
	
	/**
	 * Returns a tileset by name.
	 * @param name name of the tileset
	 * @return the tileset
	 */
	private function getTileset(name:String):Tileset
	{
		return tilesets.get(name);
	}

	/**
	 * Loads a level from a xml string using the specified asset path.
	 * @param xmlString the xml exported from Tiled.
	 * @param assetsPath Path to the assets directory from the project's root dir (usually the one containing the .nmml file).
	 * @param addToScene if this is true, the level will be added to the current state as soon as the level is loaded.
	 * @param tilemapAddCallback a callback that is called every time a tilemap is loaded.
	 * @param objectAddCallback a callback that is called every time an object (sprite) is loaded.
	 * @return a populated instance of TiledLevel.
	 */
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