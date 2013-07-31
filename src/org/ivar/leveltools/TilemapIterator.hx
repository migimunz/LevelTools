package org.ivar.leveltools;
import org.flixel.FlxTilemap;

using org.ivar.leveltools.LevelTools;

class TilemapIterator
{
	private var tilemap:FlxTilemap;
	private var curX:Int;
	private var curY:Int;
	private var endX:Int;
	private var endY:Int;

	public function new(tilemap:FlxTilemap, x1:Int, y1:Int, x2:Int, y2:Int)
	{
		this.tilemap = tilemap;
		this.curX    = tilemap.clampX(cast(Math.min(x1, x2), Int));
		this.curY    = tilemap.clampY(cast(Math.min(y1, y2), Int));
		this.endX    = tilemap.clampX(cast(Math.max(x1, x2), Int));
		this.endY    = tilemap.clampY(cast(Math.max(y1, y2), Int));
	}

	public function hasNext():Bool
	{
		return !(curY > endY);
	}

	public function next():Int
	{
		var tile:Int = tilemap.getTile(curX, curY);
		curX++;
		if(curX > endX)
		{
			curX = 0;
			curY++;
		}
		return tile;
	}
}