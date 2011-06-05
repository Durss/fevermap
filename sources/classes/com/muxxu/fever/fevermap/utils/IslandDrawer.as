package com.muxxu.fever.fevermap.utils {

	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import com.muxxu.fever.graphics.Ground1Graphic;
	import com.muxxu.fever.graphics.Ground2Graphic;
	import com.muxxu.fever.graphics.GroundGraphic;

	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 14 févr. 2011;
	 */
	public class IslandDrawer {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>IslandDrawer</code>.
		 */
		public function IslandDrawer() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Draws an item to the grid.
		 */
		public static function drawItemToGrid(target:BitmapData, value:*, px:int, py:int, cellSize:int, margin:int = 1, erase:Boolean = true, offset:Point = null, isRecursion:Boolean = false):void {
			if(value is Array) {
				drawItemToGrid(target, value[0], px, py, cellSize, margin, erase, offset, true);
				drawItemToGrid(target, value[1], px, py, cellSize, margin, erase, offset, true);
				return;
			}else if(!isRecursion && value != 0){
				var level1Values:Array = [1,2,3,"Wall","Ladder"];
				if(level1Values.indexOf(value) == -1) {
					value = [1, value];
					drawItemToGrid(target, value, px, py, cellSize, margin, erase, offset);
					return;
				}
			}
			var m:Matrix, item:DisplayObject, clazz:Class, scale:Number;
			if(offset == null) offset = new Point(0,0);
			if(value != 0) {
				if(value == 1) {
					item = new GroundGraphic();
				}else if(value == 2) {
					item = new Ground1Graphic();
				}else if(value == 3) {
					item = new Ground2Graphic();
				}

				if(item != null) {
					scale = (cellSize-margin) / item.width;
					m = new Matrix();
					m.scale(scale, scale);
					m.translate(px * cellSize + margin + offset.x, py * cellSize + margin + offset.x);
					target.draw(item, m);
				}
				
				if((isNaN(parseInt(value)) || parseInt(value) > 3) && value != null) {
					value = value.replace(/E([0-9]+)/gi, "Enemy$1");
					value = value.replace(/I([0-9]+)/gi, "Item$1");
//					trace('value: ' + (value));
					clazz = getDefinitionByName("com.muxxu.fever.graphics." + value + "Graphic") as Class;
					item = new clazz();
					if(value!="Wall" && value!="Ladder") {
						item.filters = [new DropShadowFilter(0,0,0,.7,2,2,2,2)];
					}
					m = new Matrix();
					scale	= Math.min((cellSize-margin) / item.width, (cellSize-margin) / item.height);
					m.scale(scale, scale);
					m.translate(Math.floor(px * cellSize + margin + (cellSize - item.width * scale) * .5 + offset.x),
								Math.floor(py * cellSize + margin + (cellSize - item.height * scale) * .5) + offset.x);
					target.draw(item, m);
				}
			}else if(erase) {
				target.fillRect(new Rectangle(px * cellSize + margin, py * cellSize + margin, cellSize - margin, cellSize - margin), 0);
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}