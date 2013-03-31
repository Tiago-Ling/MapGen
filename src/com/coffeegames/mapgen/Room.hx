package com.coffeegames.mapgen;
import flash.geom.Point;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class Room
{
	public var originX:Int;
	public var originY:Int;
	public var width:Int;
	public var height:Int;
	public var entrance:Door;
	public var doors:Array<Door>;
	
	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		originX = x;
		originY = y;
		this.width = width;
		this.height = height;
	}
}