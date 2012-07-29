package org.ivar.leveltools;
import haxe.xml.Fast;

/**
 * ...
 * @author Nemanja Stojanovic
 */

class Properties extends Hash<String>
{

	public function new(?node:Fast = null) 
	{
		super();
		if (node == null)
			return;
		for (property in node.nodes.property)
		{
			set(property.att.name, property.att.value);
		}
		for (property in node.nodes.prop)
		{
			set(property.att.name, property.att.value);
		}
		
	}
	
	public function getString(key:String, def:String):String
	{
		if (key != null && exists(key))
			return get(key);
		else
			return def;
	}
	
	public function getInt(key:String, ?def:Int = 0):Int
	{
		if (key != null && exists(key))
		{
			var value:Null<Int> = Std.parseInt(get(key));
			return value == null ? def : value;
		}
		else
			return def;
	}
	
	public function getFloat(key:String, ?def:Float = 0.0):Float
	{
		if (key != null && exists(key))
		{
			var value:Null<Float> = Std.parseFloat(get(key));
			return value == null ? def : value;
		}
		else
			return def;
	}
	
	public function getBool(key:String, ?def:Bool = false):Bool
	{
		if (key != null && exists(key))
		{
			var value:String = get(key).toLowerCase();
			if (value == "1" || value == "true")
				return true;
			else
				return false;
		}
		else
		{
			return def;
		}
	}
}