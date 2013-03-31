package com.coffeegames.mapgen;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * ...
 * @author Tiago Ling Alexandre
 */
class MapGenerator {
	public var display:Bitmap;
	
	public var width:Int;
	public var height:Int;
	private var numRooms:Int;
	private var roomsLeft:Int;
	
	private var currentRoomEntrance:Door;
	private var currentRoomSize:Point;
	private var map:BitmapData;
	private var parent:Sprite;
	
	public var rooms:Array<Room>;
	private var doorIndex:Int;
	private var unusedDoors:Array<Door>;
	
	private var oldDoorWallSize:Int;
	
	public var lowestX:Int;
	
	/**
	 * Create a new instance of the map generator
	 * @param	w	Width in tiles
	 * @param	h	Height in tiles
	 * @param	n	Number of rooms
	 */
	public function new(w:Int, h:Int, n:Int) {
		width = w;
		height = h;
		numRooms = roomsLeft = n;
		
		rooms = new Array<Room>();
		unusedDoors = new Array<Door>();
		doorIndex = 0;
		lowestX = 0;
		
		init();
	}
	
	public function dispose():Void {
		parent.removeChild(display);
		map = null;
		rooms = null;
		unusedDoors = null;
		currentRoomEntrance = null;
		currentRoomSize = null;
		parent = null;
	}
	
	private function init():Void {
		map = new BitmapData(width, height, false, 0xFF333333);
		
		generate();
		
		//showColorCodes();
	}
	
	private function showColorCodes():Void {
		trace("NW CORNER : " + map.getPixel32(rooms[1].originX, rooms[1].originY));
		
		trace("NE CORNER : " + map.getPixel32(rooms[0].originX + (rooms[0].width - 1), rooms[0].originY));
		
		trace("SE CORNER : " + map.getPixel32(rooms[0].originX + (rooms[0].width - 1), rooms[0].originY + (rooms[0].height - 1)));
		
		trace("SW CORNER : " + map.getPixel32(rooms[0].originX, rooms[0].originY + (rooms[0].height - 1)));
		
		trace("N WALL : " + map.getPixel32(rooms[0].originX + 1, rooms[0].originY));
		
		trace("E WALL : " + map.getPixel32(rooms[0].originX + (rooms[0].width - 1), rooms[0].originY + 1));
		
		trace("S WALL : " + map.getPixel32(rooms[0].originX + (rooms[0].width - 1) - 1, rooms[0].originY + (rooms[0].height - 1)));
		
		trace("W WALL : " + map.getPixel32(rooms[0].originX, rooms[0].originY + 1));
		
		trace("DOOR SOUTH: " + map.getPixel32(rooms[0].doors[0].x, rooms[0].doors[0].y - 1));
		trace("DOOR POS : " + rooms[0].doors[0].x + "," + (rooms[0].doors[0].y - 1));
		
		trace("DOOR EAST: " + map.getPixel32(rooms[0].doors[1].x - 1, rooms[0].doors[1].y));
		trace("DOOR POS : " + (rooms[0].doors[1].x - 1) + "," + (rooms[0].doors[1].y));
		
		trace("ENTRANCE : " + map.getPixel32(rooms[0].entrance.x, rooms[0].entrance.y));
		
		trace("FLOOR : " + map.getPixel32(rooms[0].originX + 1, rooms[0].originY + 1));
	}
	
	public function showMinimap(parent:DisplayObjectContainer, scale:Int, align:MapAlign):Void {
		display = new Bitmap(map);
		parent.addChild(display);
		display.scaleX = scale;
		display.scaleY = scale;
		switch (align) {
			case MapAlign.TopLeft:
				display.x = 10;
				display.y = 10;
			case MapAlign.TopRight:
				display.x = (parent.stage.stageWidth - display.width) - 10;
				display.y = 10;
			case MapAlign.BottomLeft:
				display.x = 10;
				display.y = (parent.stage.stageHeight - display.height) - 10;
			case MapAlign.BottomRight:
				display.x = (parent.stage.stageWidth - display.width) - 10;
				display.y = (parent.stage.stageHeight - display.height) - 10;
			case MapAlign.Center:
				display.x = (parent.stage.stageWidth / 2) - (display.width / 2);
				display.y = (parent.stage.stageHeight / 2) - (display.height / 2);
		}
		
		
	}
	
	private function generate():Void {
		
		while (roomsLeft > 0) {
			if (roomsLeft == numRooms) { //First room
				var dType:DoorType = getRand(0, 1) == 0 ? DoorType.North : DoorType.West;
				//trace( "dType : " + dType );
				currentRoomEntrance = new Door(0, 0, dType);
			} else {
				if (currentRoomEntrance.type == DoorType.South) {
					currentRoomEntrance.y++;
				} else {
					currentRoomEntrance.x++;
				}
			}
			
			currentRoomSize = getRoomSize();
			
			var room:Room = new Room(Std.int(currentRoomEntrance.x), Std.int(currentRoomEntrance.y), Std.int(currentRoomSize.x), Std.int(currentRoomSize.y));
			
			room.entrance = currentRoomEntrance;
			if (roomsLeft == numRooms) {
				if (room.entrance.type == DoorType.North) {
					room.entrance.x = Std.int(room.originX + (room.width / 2));
					room.entrance.y = 0;
				} else if (room.entrance.type == DoorType.West) {
					room.entrance.x = 0;
					room.entrance.y = Std.int(room.originY + (room.height / 2));
				}
			}
			
			//Compare currentRoomSize with previousRoomSize and align them
			if (roomsLeft < numRooms) {
				if (currentRoomEntrance.type == DoorType.South) {
					//room.originX -= Std.int(oldDoorWallSize / 2);
					room.originX -= Std.int(room.width / 2);
				} else {
					//room.originY -= Std.int(oldDoorWallSize / 2);
					room.originY -= Std.int(room.height / 2);
				}
			}
			
			//Door placement
			var southDoor:Door = new Door(Std.int(room.originX + (room.width / 2)), Std.int(room.originY + (room.height - 1)), DoorType.South);
			var eastDoor:Door = new Door(Std.int(room.originX + (room.width - 1)), Std.int(room.originY + (room.height / 2)), DoorType.East);
			room.doors = new Array<Door>();
			room.doors.push(southDoor);
			room.doors.push(eastDoor);
			
			if (checkRoomSpace(room) == true) {
				//Choose one the rooms' doors to be the currentRoomEntrance
				//currentRoomEntrance = getRand(0, 1) == 0 ? room.doors[0] : room.doors[1];
				var nextDoorID:Int = getRand(0, 1);
				if (nextDoorID == 0) {
					currentRoomEntrance = room.doors[0];
					//unusedDoors.push(room.doors[1]);
					unusedDoors.push(room.doors[0]);
				} else {
					currentRoomEntrance = room.doors[1];
					//unusedDoors.push(room.doors[0]);
					unusedDoors.push(room.doors[1]);
				}
				
				//Print room
				printRoom(room);
				roomsLeft--;
				rooms.push(room);
			} else {
				//Try to reduce size of the room to make it fit
				if (reduceRoom(room) == true) {
					var nextDoorID:Int = getRand(0, 1);
					if (nextDoorID == 0) {
						currentRoomEntrance = room.doors[0];
						unusedDoors.push(room.doors[1]);
					} else {
						currentRoomEntrance = room.doors[1];
						unusedDoors.push(room.doors[0]);
					}
					
					//Print room
					printRoom(room);
					roomsLeft--;
					rooms.push(room);
				} else {
					if (unusedDoors[doorIndex] != null) {
						currentRoomEntrance = unusedDoors[doorIndex];
						doorIndex++;
					} else {
						roomsLeft--;
					}
				}
			}
		}
		
		trace("THE END -- TOTAL ROOMS PLACED : " + rooms.length);
	}
	
	private function reduceRoom(room:Room):Bool {
		//Try to reduce -1w, then -1h, -2w & finally -2h
		//Then check to see if room is equal or larger than minimal space (5)
		
		for (i in 0...4) {
			switch (i) {
				case 0:
					room.width--;
					if (room.width <= 5) {
						room.width = 5;
					}
					if (checkRoomSpace(room) == true) {
						var southDoor:Door = new Door(Std.int(room.originX + (room.width / 2)), Std.int(room.originY + (room.height - 1)), DoorType.South);
						var eastDoor:Door = new Door(Std.int(room.originX + (room.width - 1)), Std.int(room.originY + (room.height / 2)), DoorType.East);
						room.doors[0] = southDoor;
						room.doors[1] = eastDoor;
						return true;
					}
				case 1:
					room.height--;
					if (room.height <= 5) {
						room.height = 5;
					}
					if (checkRoomSpace(room) == true) {
						var southDoor:Door = new Door(Std.int(room.originX + (room.width / 2)), Std.int(room.originY + (room.height - 1)), DoorType.South);
						var eastDoor:Door = new Door(Std.int(room.originX + (room.width - 1)), Std.int(room.originY + (room.height / 2)), DoorType.East);
						room.doors[0] = southDoor;
						room.doors[1] = eastDoor;
						return true;
					}
				case 2:
					room.width -= 2;
					if (room.width <= 5) {
						room.width = 5;
					}
					if (checkRoomSpace(room) == true) {
						var southDoor:Door = new Door(Std.int(room.originX + (room.width / 2)), Std.int(room.originY + (room.height - 1)), DoorType.South);
						var eastDoor:Door = new Door(Std.int(room.originX + (room.width - 1)), Std.int(room.originY + (room.height / 2)), DoorType.East);
						room.doors[0] = southDoor;
						room.doors[1] = eastDoor;
						return true;
					}
				case 3:
					room.height -= 2;
					if (room.height <= 5) {
						room.height = 5;
					}
					if (checkRoomSpace(room) == true) {
						var southDoor:Door = new Door(Std.int(room.originX + (room.width / 2)), Std.int(room.originY + (room.height - 1)), DoorType.South);
						var eastDoor:Door = new Door(Std.int(room.originX + (room.width - 1)), Std.int(room.originY + (room.height / 2)), DoorType.East);
						room.doors[0] = southDoor;
						room.doors[1] = eastDoor;
						return true;
					}
			}
		}
		
		return false;
	}
	
	private function printRoom(room:Room):Void {
		var startX:Int = room.originX;
		var startY:Int = room.originY;
		var endX:Int = startX + room.width;
		var endY:Int = startY + room.height;
		
		for (countY in startY...endY) {
			for (countX in startX...endX) {
				if (countX == startX && countY == startY) { // NW CORNER
					//map.setPixel32(countX, countY, 0xFFA30008);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == (endX - 1) && countY == startY) { // NE CORNER
					//map.setPixel32(countX, countY, 0xFFBC2F36);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == startX && countY == (endY - 1)) { // SW CORNER
					//map.setPixel32(countX, countY, 0xFFFD7279);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == (endX - 1) && countY == (endY - 1)) { // SE CORNER
					//map.setPixel32(countX, countY, 0xFFFD3F49);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == room.entrance.x && countY == room.entrance.y) { //ENTRANCE
					map.setPixel32(room.entrance.x, room.entrance.y, 0xFF82217A);
					
				} else if (countX == startX) { // NORTH WALL
					//map.setPixel32(countX, countY, 0xFF1D0772);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countY == startY) { // WEST WALL
					//map.setPixel32(countX, countY, 0xFF856FD7);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == room.doors[1].x && countY == room.doors[1].y) { //DOOR EAST
					//map.setPixel32(countX, countY, 0xFFBFA530);
					map.setPixel32(countX, countY, 0xFFFFD100);
					
				} else if (countX == (endX - 1)) { // EAST WALL
					//map.setPixel32(countX, countY, 0xFF3F2D84);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else if (countX == room.doors[0].x && countY == room.doors[0].y) { //DOOR SOUTH
					map.setPixel32(countX, countY, 0xFFFFD100);
					
				} else if (countY == (endY - 1)) { // SOUTH WALL
					//map.setPixel32(countX, countY, 0xFF6749D7);
					map.setPixel32(countX, countY, 0xFF4C57D8);
					
				} else { // GROUND
					map.setPixel32(countX, countY, 0xFFFFFFFF);
				}
			}
		}
		
		
		//Testing not used doors
/*		var unDoorLen:Int = unusedDoors.length;
		trace( "unDoorLen : " + unDoorLen );
		for (i in 0...unDoorLen) {
			if (unusedDoors[i].type == DoorType.South) {
				map.setPixel32(unusedDoors[i].x, unusedDoors[i].y, 0xFF00FF00);
			} else {
				map.setPixel32(unusedDoors[i].x, unusedDoors[i].y, 0xFF00FF00);
			}
		}*/
		
	}
	
	//HELPERS
	private function checkRoomSpace(room:Room):Bool {
		var startX:Int = room.originX;
		var startY:Int = room.originY;
		var endX:Int = startX + room.width;
		var endY:Int = startY + room.height;
		
		if (endX < 0 || endX > map.width || endY < 0 || endY > map.height) {
			return false;
		}
		
		for (i in startY...endY) {
			for (j in startX...endX) {
				if (map.getPixel32(j, i) != 4281545523) {
				return false;
				}
			}
		}
		
		return true;
	}
	
	private function getRoomSize():Point {
		var width:Int = -1;
		var height:Int = -1;
		var counter:Int = getRand(0, 3);
		switch (counter) {
			case 0:
				//width = 5;
				width = 7;
			case 1:
				//width = 7;
				width = 9;
			case 2:
				//width = 9;
				width = 11;
			case 3:
				//width = 11;
				width = 13;
		}
		
		counter = getRand(0, 3);
		switch (counter) {
			case 0:
				//height = 5;
				height = 7;
			case 1:
				//height = 7;
				height = 9;
			case 2:
				//height = 9;
				height = 11;
			case 3:
				//height = 11;
				height = 13;
		}
		
		return new Point(width, height);
	}
	
	private function getRand(min:Int, max:Int):Int {
		return Math.floor(min + (Math.random() * (max + 1 - min)));
	}
	
}