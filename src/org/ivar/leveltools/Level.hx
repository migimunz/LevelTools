package org.ivar.leveltools;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;
import nme.installer.Assets;

typedef ObjectAddCallback 	= FlxSprite -> Properties -> Void;
typedef TilemapAddCallback 	= FlxTilemap -> Void;
/**
 * ...
 * @author Nemanja Stojanovic
 */


 
class Level 
{
	
	private var masterLayer:FlxGroup;
	private var tilemaps:Hash<FlxTilemap>;
	private var layers:Hash<FlxGroup>;

	private var	name:String = "";
	private var assetsPath:String = "assets/";
	private var objectAddCallback:ObjectAddCallback;
	private var tilemapAddCallback:TilemapAddCallback;
	
	public function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback) 
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