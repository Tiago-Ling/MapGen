package com.coffeegames.mapgen;
import flash.geom.Point;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Room
{
	//public var origin:Point;
	public var originX:Int;
	public var originY:Int;
	public var width:Int;
	public var height:Int;
	
	//public var entrance:DoorType;
	public var entrance:Door;
	
	//public var doors:Array<Point>;
	public var doors:Array<Door>;
	
	//public var tiles:Array<IDepthModifier>;
	//public var ground:Array<IDepthModifier>;
	
	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		//this.origin = origin;
		originX = x;
		originY = y;
		this.width = width;
		this.height = height;
		//this.entrance = entrance;
		//tiles = new Array<IDepthModifier>();
		//ground = new Array<IDepthModifier>();
	}
	
/*	public function setChildVisibility(value:Bool):Void {
		var numTiles:Int = tiles.length;
		for (i in 0...numTiles) {
			tiles[i].view.visible = value;
		}
		
		//var numGTiles:Int = ground.length;
		//for (i in 0...numGTiles) {
			//ground[i].view.visible = value;
		//}
	}*/
	
}