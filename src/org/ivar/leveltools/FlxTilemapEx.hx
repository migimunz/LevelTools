package org.ivar.leveltools;
import flash.geom.ColorTransform;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author k.nepomnyaschiy
 */
class FlxTilemapEx extends FlxTilemap
{
	
	
	public var color(default, set_color):UInt = 0;
	
	private function set_color(Color:UInt):UInt
	{
		_tiles.colorTransform(_tiles.rect, intToColorTransform(Color));
		return Color;
	}
	
	private inline static function intToColorTransform(Color:UInt):ColorTransform
	{
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.redMultiplier = (Color >> 16) / 255;
		colorTransform.greenMultiplier = (Color >> 8 & 0xff) / 255;
		colorTransform.blueMultiplier = (Color & 0xff) / 255;
	
		return colorTransform;
	}
	
}