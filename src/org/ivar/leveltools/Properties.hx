package org.ivar.leveltools;
import haxe.xml.Fast;

/**
 * @author Nemanja Stojanovic
 * This class is used to easily parse key-value properties exported from Dame and Tiled. 
 * It provides some useful methods for retreiving values and allows the user to specify 
 * default values for properties.
 */
class Properties extends Hash<String>
{

	/**
	 * Constructs the object and loads all the properties into the hash table.
	 * Both keys and values are strings (as this class extends Hash), but helper methods
	 * provide conversions to other basic types. It treats all nodes named <code>prop</code> and
	 * <code>property</code> as properties and reads their <code>name</code> and <code>value</code> 
	 * attributes.
	 * @param node The node that contains all the properties.
	 * @return Nothing.
	 */
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
	
	/**
	 * Returns the value of a property as a string, or the default value.
	 * @param key name of the property.
	 * @param def default value that is returned if the key is not present.
	 * @return Value of the property.
	 */
	public function getString(key:String, ?def:String = ""):String
	{
		if (key != null && exists(key))
			return get(key);
		else
			return def;
	}
	
	/**
	 * Returns the value of a property as an int, or the default value.
	 * @param key name of the property.
	 * @param def default value that is returned if the key is not present.
	 * @return Value of the property.
	 */
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
	
	/**
	 * Returns the value of a property as a float, or the default value.
	 * @param key name of the property.
	 * @param def default value that is returned if the key is not present.
	 * @return Value of the property.
	 */
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
	
	/**
	 * Returns the value of a property as a boolean, or the default value.
	 * Values "1" and "true" are treated as true, everything else is treated as false.
	 * @param key name of the property.
	 * @param def default value that is returned if the key is not present.
	 * @return Value of the property.
	 */
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