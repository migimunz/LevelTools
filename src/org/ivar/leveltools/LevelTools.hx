package org.ivar.leveltools;
import flixel.FlxTilemap;
import org.ivar.leveltools.TilemapIterator;

/**
 * A structure that contains the data about the current tile. Passed as an argument to callbacks
 * from each* functions.
 */
typedef TileData = 
{
	/**
	 * The id of the current tile.
	 */
	var tileId:Int;

	/**
	 * The x coordinate of the current tile.
	 */	
	var x:Int;

	/**
	 * The y coordinate of the current tile.
	 */
	var y:Int;

	/**
	 * The tilemap the tile belongs to.
	 */
	var tilemap:FlxTilemap;
}

/**
 * @author Nemanja Stojanovic
 * A static class that provides extension methods for FlxTilemap. 
 */
class LevelTools
{

	/**
	 * Clamps a value to the width of the tilemap.
	 * @param tilemap the tilemap.
	 * @param value value to be clamped.
	 * @return clamped value.
	 */
	public static function clampX(tilemap:FlxTilemap, value:Int):Int
	{
		value = value < 0 ? 0 : value;
		value = value >= tilemap.widthInTiles ? tilemap.widthInTiles - 1 : 0;
		return value;
	}

	/**
	 * Clamps a value to the height of the tilemap.
	 * @param tilemap the tilemap.
	 * @param value value to be clamped.
	 * @return clamped value.
	 */
	public static function clampY(tilemap:FlxTilemap, value:Int):Int
	{
		value = value < 0 ? 0 : value;
		value = value >= tilemap.heightInTiles ? tilemap.heightInTiles - 1 : 0;
		return value;
	}

	/**
	 * Clamps a value to be in range of the minimum and maximum tile index.
	 * @param tilemap the tilemap.
	 * @param idx index to be clamped.
	 * @return clamped value.
	 */
	public static function clampIndex(tilemap:FlxTilemap, idx:Int):Int
	{
		idx = idx < 0 ? 0 : idx;
		idx = idx >= tilemap.totalTiles ? tilemap.totalTiles -1 : idx;
		return idx;
	}

	/**
	 * Converts tile coordinates to a tile index.
	 * @param tilemap the tilemap.
	 * @param x The x coordinate.
	 * @param y The y coordinate.
	 * @return index of the tile.
	 */
	public static function toIndex(tilemap:FlxTilemap, x:Int, y:Int):Int
	{
		var idx:Int = y * tilemap.widthInTiles + x;
		return clampIndex(tilemap, idx);
	}

	/**
	 * Creates a tilemap iterator that iterates the specified range. The range values are
	 * specified as an AABB and are clamped to the tilemap size. Tiles are iterated from left 
	 * to right, top to bottom.
	 * @param tilemap the tilemap.
	 * @param x1 x of the top left point of the rectangle.
	 * @param y1 y of the top left point of the rectangle.
	 * @param x2 x of the bottom right point of the rectangle.
	 * @param y2 y of the bottom right point of the rectangle.
	 * @return A tilemap iterator.
	 */
	public static function iterRange(tilemap:FlxTilemap, x1:Int, y1:Int, x2:Int, y2:Int):TilemapIterator
	{
		return new TilemapIterator(tilemap, x1, y1, x2, y2);
	}

	/**
	 * Creates a tilemap iterator that iterates the whole tilemap. Tiles are iterated from left 
	 * to right, top to bottom.
	 * @param tilemap the tilemap.
	 * @return A tilemap iterator.
	 */
	public static function iterAll(tilemap:FlxTilemap):TilemapIterator
	{
		return new TilemapIterator(tilemap, 0, 0, tilemap.widthInTiles, tilemap.heightInTiles);
	}

	/**
	 * Iterates over each tile in the specified range, calling the callback function 
	 * <code>f</code>, passing an instance of <code>TileData</code>. Tiles are iterated from left 
	 * to right, top to bottom.
	 * @param tilemap the tilemap.
	 * @param x1 x of the top left point of the rectangle.
	 * @param y1 y of the top left point of the rectangle.
	 * @param x2 x of the bottom right point of the rectangle.
	 * @param y2 y of the bottom right point of the rectangle.
	 * @param f function that is called on each tile.
	 * @return the tilemap passed as the first argument.
	 */
	public static function eachRange(tilemap:FlxTilemap, x1:Int, y1:Int, x2:Int, y2:Int, f:TileData->Void):FlxTilemap
	{
		if(f == null)
			return tilemap;
		var data:TileData = { tileId: 0, x: 0, y: 0, tilemap: tilemap };
		x1 = clampX(tilemap, cast(Math.min(x1, x2), Int));
		y1 = clampY(tilemap, cast(Math.min(y1, y2), Int));
		x2 = clampX(tilemap, cast(Math.max(x1, x2), Int));
		y2 = clampY(tilemap, cast(Math.max(y1, y2), Int));
		for(tileY in y1 ... y2)
			for(tileX in x1 ... x2)
			{
				data.tileId = tilemap.getTile(tileX, tileY);
				data.x = tileX;
				data.y = tileY;
				f(data);
			}
		return tilemap;
	}

	/**
	 * Iterates over each tile with the specified ID, calling the callback function 
	 * <code>f</code>, passing an instance of <code>TileData</code>. Tiles are iterated from left 
	 * to right, top to bottom.
	 * @param tilemap the tilemap.
	 * @param tileId tile id to filter on.
	 * @param f function that is called on each tile.
	 * @return the tilemap passed as the first argument.
	 */
	public static function eachWithId(tilemap:FlxTilemap, tileId:Int, f:TileData->Void):FlxTilemap
	{
		return each(tilemap, function(data:TileData)
		{
			if(data.tileId == tileId)
				f(data);
		});
	}

	/**
	 * Iterates over each tile in the tilemap, calling the callback function 
	 * <code>f</code>, passing an instance of <code>TileData</code>. Tiles are iterated from left 
	 * to right, top to bottom.
	 * @param tilemap the tilemap.
	 * @param f function that is called on each tile.
	 * @return the tilemap passed as the first argument.
	 */
	public static function each(tilemap:FlxTilemap, f:TileData->Void):FlxTilemap
	{
		return eachRange(tilemap, 0, 0, tilemap.widthInTiles, tilemap.heightInTiles, f);
	}

	/**
	 * Replaces all tile IDs with <code>newId</code>.
	 * @param tilemap the tilemap.
	 * @param oldId the tile ID to replace.
	 * @param oldId the tile ID to replace it with.
	 * @return the tilemap passed as the first argument.
	 */
	public static function replace(tilemap:FlxTilemap, oldId:Int, newId:Int):FlxTilemap
	{
		return each(tilemap, function(data:TileData)
		{
			if(data.tileId == oldId)
			{
				data.tilemap.setTile(data.x, data.y, newId);
			}
		});
	}

}