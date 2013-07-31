package org.ivar.leveltools;
import org.flixel.FlxTilemap;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import openfl.Assets;

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
	private var tilemaps:Map<String, FlxTilemap>;

	/**
	 * A table that contains all the layers regardless of type, by the name of the layer.
	 */
	private var layers:Map<String, FlxGroup>;

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
		tilemaps			 		= new Map<String, FlxTilemap>();
		layers						= new Map<String, FlxGroup>();
		this.assetsPath = assetsPath;
	}
	
	/**
	 * Returns a tilemap with the name <code>name</code>.
	 * @param name name of the tilemap.
	 * @return the tilemap or null if it doesn't exist.
	 */
	public function getTilemap(name:String):FlxTilemap
	{
		return tilemaps.get(name);
	}
	
	/**
	 * Returns a layer with the name <code>name</code>.
	 * @param name name of the layer.
	 * @return the layer or null if it doesn't exist.
	 */
	public function getLayer(name:String):FlxGroup
	{
		return layers.get(name);
	}

	/**
	 * Returns the master layer.
	 * @return the master layer.
	 */
	public function getMasterLayer():FlxGroup
	{
		return masterLayer;
	}
	
}