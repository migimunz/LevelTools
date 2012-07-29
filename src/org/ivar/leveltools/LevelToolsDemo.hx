package org.ivar.leveltools;

import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import org.flixel.FlxGame;
/**
 * ...
 * @author migimunz
 */

class LevelToolsDemo extends FlxGame
{

	public function new() 
	{
		super(320, 240, DemoState, 2, 60, 60);
	}
	
	static public function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new LevelToolsDemo());
	}
}