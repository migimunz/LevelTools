package org.ivar.leveltools;
import haxe.xml.Fast;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxObject;
import org.flixel.FlxTilemap;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.ivar.leveltools.Level;
import nme.installer.Assets;


/**
 * A function type used as a callback for adding links.
 */
typedef LinkAddCallback = FlxSprite -> FlxSprite -> Properties -> Void;

/**
 * @author Nemanja Stojanovic
 * This class deals with loading levels exported from DAME. It currently supports
 * loading tilemap layers, sprite layers, paths layers and links between sprites. 
 * Properties are loaded into a key-value structure and passed as arguments to callbacks, 
 * however, individual tile properties are not yet supported.
 */
class DameLevel extends Level
{
	/**
	 * A table of registered link IDs used to link sprites.
	 */
	private var linkIds:Hash<FlxSprite>;

	/**
	 * A table of parsed paths, stored by name.
	 */
	private var paths:Hash<FlxPath>;

	/**
	* A callback that is called whenever a link is loaded.
	*/
	private var linkAddCallback:LinkAddCallback;
	
	/**
	* Constructs the object, initializes members and callbacks but doesn't actually load
	* the level.
	* @param assetsPath Path to the assets directory from the project's root dir (usually the one containing the .nmml file).
	* @param tilemapAddCallback a callback that is called every time a tilemap is loaded.
	* @param objectAddCallback a callback that is called every time an object (sprite) is loaded.
	* @param linkAddCallback a callback that is called every time a link is loaded.
	*/
	public function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback, linkAddCallback:LinkAddCallback) 
	{
		super(assetsPath, tilemapAddCallback, objectAddCallback);
		this.linkAddCallback = linkAddCallback;
		linkIds = new Hash<FlxSprite>();
		paths 	= new Hash<FlxPath>();
	}
	
	/**
	 * Parses a level from a loaded xml file.
	 * @param addToScene if this is true, the level will be added to the current state as soon as the level is loaded.
	 * @param xml the loaded xml file containing the level to be loaded.
	 * @return Nothing.
	 */
	private function parseLevel(addToScene:Bool, xml:Fast):Void
	{
		name = xml.att.name;
		for (layer in xml.nodes.layer)
			parseLayer(layer);
		
		if (xml.hasNode.links)
			parseLinks(xml.node.links);
		
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
		var group:FlxGroup = new FlxGroup();
		for (node in layerNode.elements)
		{
			switch(node.name)
			{
				case "map":
					parseTilemap(group, node, layerNode);
				case "sprite":
					parseSprite(group, node, layerNode);
				case "path":
					parsePath(group, node, layerNode);
			}
		}
		var scroll = new FlxPoint(Std.parseFloat(layerNode.att.xScroll), Std.parseFloat(layerNode.att.yScroll));
		if(scroll.x != 1.0 || scroll.y != 1.0)
			group.setAll("scrollFactor", scroll);
		layers.set(layerNode.att.name, group);
		masterLayer.add(group);
	}
	
	/**
	 * Loads a tilemap and adds it to the layer group. 
	 * If specified, the tilemapAddCallback is called with the loaded tilemap as argument.
	 * @param group The group of the layer this map belongs to
	 * @param mapNode The node that contains tilemap data
	 * @param layerNode The node that contains layer data
	 * @return Nothing.
	 */
	private function parseTilemap(group:FlxGroup, mapNode:Fast, layerNode:Fast):Void
	{
		var map:FlxTilemap = new FlxTilemap();
		map.loadMap(
			Assets.getText(assetsPath + mapNode.att.csv),
			assetsPath + mapNode.att.tiles,
			Std.parseInt(mapNode.att.tileWidth),
			Std.parseInt(mapNode.att.tileHeight),
			0, 0,
			Std.parseInt(mapNode.att.drawIdx),
			Std.parseInt(mapNode.att.collIdx));
		map.setSolid(mapNode.has.hasHits && mapNode.att.hasHits == "true");
			
		tilemaps.set(layerNode.att.name, map);
		group.add(map);
		if (tilemapAddCallback != null)
			tilemapAddCallback(map);
	}

	/**
	 * Loads a sprite and adds it to the layer group. The sprite is created using reflection, 
	 * from the class name specified in Dame (the class name should contain the whole package). 
	 * If the class doesn't exist, it is simply skipped. If the objectAddCallback is specified, 
	 * it is called with the loaded sprite and it's properties as arguments.
	 * @todo Maybe throw an exception when the sprite doesn't exist?
	 * @param group The group of the layer this sprite belongs to.
	 * @param spriteNode The node that contains sprite data
	 * @param layerNode The node that contains layer data
	 * @return Nothing.
	 */
	private function parseSprite(group:FlxGroup, spriteNode:Fast, layerNode:Fast):Void
	{
		var spriteClass	= Type.resolveClass(spriteNode.x.get("class"));
		if (spriteClass == null)
			return;
		//Since Type.createInstance can't deal with optional args, we have to pass all
		//declared arguments manually. 
		var constructor = Std.string(Reflect.field(spriteClass, "new"));
		var arity = Std.parseInt(constructor.substr(constructor.indexOf(":") + 1));
		var args = [];
		for(i in 0 ... arity)
			args.push(null);
		
		var sprite:FlxSprite = cast(Type.createInstance(spriteClass, args), FlxSprite);
		sprite.x 		= Std.parseFloat(spriteNode.att.x);
		sprite.y 		= Std.parseFloat(spriteNode.att.y);
		sprite.angle	= Std.parseFloat(spriteNode.att.angle);
		sprite.scale.x  = Std.parseFloat(spriteNode.att.xScale);
		sprite.scale.y  = Std.parseFloat(spriteNode.att.yScale);
		sprite.facing   = spriteNode.att.flip == "true" ? FlxObject.LEFT : FlxObject.RIGHT;

		if (spriteNode.has.linkId)
			linkIds.set(spriteNode.att.linkId, sprite);
			
		var properties:Properties;
		if (spriteNode.hasNode.properties)
			properties = new Properties(spriteNode.node.properties);
		else
			properties = new Properties();
		
		group.add(sprite);
		if (objectAddCallback != null)
			objectAddCallback(sprite, properties);
	}
	
	/**
	 * Loads a path and adds it to the paths table under the name of the layer. Currently, 
	 * only one path per layer is supported, until I find a better way to do this.
	 * @todo Find a way around the path naming issue
	 * @param group The group of the layer this path belongs to.
	 * @param pathNode The node that contains path data
	 * @param layerNode The node that contains layer data
	 * @return Nothing.
	 */
	private function parsePath(group:FlxGroup, pathNode:Fast, layerNode:Fast):Void
	{
		var name:String = layerNode.att.name;
		var nodesNode:Fast = pathNode.node.nodes;
		var path:FlxPath = new FlxPath();
		for (node in nodesNode.nodes.node)
		{
			path.add(Std.parseFloat(node.att.x), Std.parseFloat(node.att.y));
		}
		paths.set(name, path);
	}
	
	/**
	 * Loads a link and calls the LinkAddCallback, passing the two linked sprites and the properties 
	 * of the link. If the sprites the link references do not exist, the link is simply skipped.
	 * @param linkNode The node that contains link data
	 * @return Nothing.
	 */
	private function parseLinks(linkNode:Fast):Void
	{
		for (link in linkNode.nodes.link)
		{
			var fromId:String = link.att.from;
			var toId:String = link.att.to;			
			if (linkIds.exists(fromId) && linkIds.exists(toId))
			{
				var properties:Properties;
				if (link.hasNode.properties)
					properties = new Properties(link.node.properties);
				else
					properties = new Properties();
				if (linkAddCallback != null)
					linkAddCallback(linkIds.get(fromId), linkIds.get(toId), properties);
			}
		}
	}
	
	/**
	 * Loads a level from a xml string using the specified asset path.
	 * @param xmlString the xml exported from DAME.
	 * @param assetsPath Path to the assets directory from the project's root dir (usually the one containing the .nmml file).
	 * @param addToScene if this is true, the level will be added to the current state as soon as the level is loaded.
	 * @param tilemapAddCallback a callback that is called every time a tilemap is loaded.
	 * @param objectAddCallback a callback that is called every time an object (sprite) is loaded.
	 * @param linkAddCallback a callback that is called every time a link is loaded.
	 * @return a populated instance of DameLevel.
	 */
	public static function loadLevel(xmlString:String,
		?assetsPath:String = "",
		?addToScene:Bool = true,
		?tilemapAddCallback:TilemapAddCallback = null,
		?objectAddCallback:ObjectAddCallback = null,
		?linkAddCallback:LinkAddCallback = null):DameLevel
	{
		var parsedXml:Xml = Xml.parse(xmlString);
		var fastXml:Fast = new Fast(parsedXml.firstElement());
		
		var level:DameLevel = new DameLevel(assetsPath, tilemapAddCallback, objectAddCallback, linkAddCallback);
		level.parseLevel(addToScene, fastXml);
		return level;
	}
	
	/**
	 * Returns a path with the specified name.
	 * @param name name of the path.
	 * @return a FlxPath instance if the path is found, null otherwise.
	 */
	public function getPath(name:String):FlxPath
	{
		return paths.get(name);
	}
	
}