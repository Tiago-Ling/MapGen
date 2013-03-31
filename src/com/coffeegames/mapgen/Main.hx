package com.coffeegames.mapgen;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

/**
 * ...
 * @author Tiago Ling Alexandre
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		var main:Main = new Main();
	}
	
	public function new() {
		//trace("Test");
		//var mapGen:MapGenerator = new MapGenerator(30, 20, 4);
		//var mapGen:MapGenerator = new MapGenerator(60, 40, 16);
		var mapGen:MapGenerator = new MapGenerator(60, 40, 20);
		mapGen.showMinimap(Lib.current, 8, MapAlign.Center);
	}
	
}