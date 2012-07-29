package org.ivar.leveltools;
import haxe.xml.Fast;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxObject;
import org.flixel.FlxTilemap;
import org.flixel.FlxPath;
import org.ivar.leveltools.Level;
import nme.installer.Assets;
/**
 * ...
 * @author Nemanja Stojanovic
 */

typedef LinkAddCallback = FlxSprite -> FlxSprite -> Properties -> Void;
 
class DameLevel extends Level
{
	private var linkIds:Hash<FlxSprite>;
	private var paths:Hash<FlxPath>;
	private var linkAddCallback:LinkAddCallback;
	
	public function new(assetsPath:String, tilemapAddCallback:TilemapAddCallback, objectAddCallback:ObjectAddCallback, linkAddCallback:LinkAddCallback) 
	{
		super(assetsPath, tilemapAddCallback, objectAddCallback);
		this.linkAddCallback = linkAddCallback;
		linkIds = new Hash<FlxSprite>();
		paths 	= new Hash<FlxPath>();
	}
	
	private function parseLevel(addToScene:Bool, xml:Fast):Void
	{
		//<level name="Level1" minx="0" miny="0" maxx="320" maxy="320" bgColor = "0xff777777" >
		name = xml.att.name;
		for (layer in xml.nodes.layer)
			parseLayer(layer);
		
		if (xml.hasNode.links)
			parseLinks(xml.node.links);
		
		if (addToScene)
			FlxG.getState().add(masterLayer);
	}
	
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
		layers.set(layerNode.att.name, group);
		masterLayer.add(group);
	}
	
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
		map.scrollFactor.x 	= Std.parseFloat(layerNode.att.xScroll);
		map.scrollFactor.y 	= Std.parseFloat(layerNode.att.yScroll);
		map.setSolid(mapNode.has.hasHits && mapNode.att.hasHits == "true");
			
		tilemaps.set(layerNode.att.name, map);
		group.add(map);
		if (tilemapAddCallback != null)
			tilemapAddCallback(map);
	}

	private function parseSprite(group:FlxGroup, spriteNode:Fast, layerNode:Fast):Void
	{
		var spriteClass	= Type.resolveClass(spriteNode.x.get("class"));
		if (spriteClass == null)
			return;
		var sprite:FlxSprite = cast(Type.createInstance(spriteClass, []), FlxSprite);
		
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
	
	public function getPath(name:String):FlxPath
	{
		return paths.get(name);
	}
	
}