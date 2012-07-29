package org.ivar.leveltools;
import org.flixel.FlxState;
import org.flixel.FlxText;
import nme.installer.Assets;
/**
 * ...
 * @author migimunz
 */

class DemoState extends FlxState
{
	private var level:DameLevel;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		level = DameLevel.loadLevel(
			Assets.getText("assets/demo/DameProject/Level_Level1.xml"), 
			"assets/demo/", 
			true,
			null,
			null,
			null
			);
	}
	
}