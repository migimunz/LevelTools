package org.ivar.leveltools;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;
import nme.installer.Assets;

/**
 * A function type used as a callback for adding objects.
 */
typedef ObjectAddCallback 	= FlxSprite -> Properties -> Void;

/**
 * A function type used as a callback for adding tilemaps.
 */
typedef TilemapAddCallback 	= FlxTilemap -> Void;

/**
 * @author Nemanja Stojanovic
 * The base class of other level loaders.
 */
class Level 
{
	/**
	 * The group that contains all other groups.
	 */
	private var masterLayer:FlxGroup;

	/**
	 * A table that contains the loaded tilemaps stored by name of the layer.
	 */
	private var tilemaps:Hash<FlxTilemap>;

	/**
	 * A table that contains all the layers regardless of type, by the name of the layer.
	 */
	private var layers:Hash<FlxGroup>;

	/**
	 * Name of the level.
	 */
	private var name:String;

	/**
	 * Path to the assets directory.
	 */ 
	private var assetsPath:String = "assets/";

	/**
	* A callback that is called whenever an object is loaded.
	*/
	private var objectAddCallback:ObjectAddCallback;

	/**
	* A callback that is called whenever a tilemap is loaded.
	*/
	private var tilemapAddCallback:TilemapAddCallback;
	
	/**
	* Constructs the objects, initalizes the default values.
	* @param assetsPath Path to the assets directory from the project's root dir (usually the one containing the .nmml file).
	* @param tilemapAddCallback a callback that is called every time a tilemap is loaded.
	* @param objectAddCallback a callback that is called every time an object (sprite) is loaded.
	*/
	private function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback) 
	{
		this.tilemapAddCallback 	= tilemapAddCallback;
		this.objectAddCallback 		= objectAddCallback;
		masterLayer 				= new FlxGroup();
		tilemaps			 		= new Hash<FlxTilemap>();
		layers						= new Hash<FlxGroup>();
		this.assetsPath = assetsPath;
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
	
	public function getTilemap(name:String):FlxTilemap
	{
		return tilemaps.get(name);
	}
	
	public function getLayer(name:String):FlxGroup
	{
		return layers.get(name);
	}

	
}