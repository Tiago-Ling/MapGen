package com.coffeegames.mapgen;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

/**
 * ...
 * @author Tiago Ling Alexandre
 */

class Main 
{
	var mapGen:MapGenerator;
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		var main:Main = new Main();
	}
	
	public function new() {
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUp);
		
		init();
	}
	
	private function init():Void {
		mapGen = new MapGenerator(60, 40, 3, true);
		mapGen.showMinimap(Lib.current, 8, MapAlign.Center);
	}
	
	private function onKeyUp(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.SPACE) {
			mapGen.generate();
		}
		
		if (e.keyCode == Keyboard.ENTER) {
			mapGen.dispose(Lib.current);
			init();
		}
	}
	
}