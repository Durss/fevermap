package com.muxxu.fever.fevermap.components.form {	import com.muxxu.fever.fevermap.data.Constants;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.data.DataManager;
	import flash.geom.Point;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import flash.events.Event;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Sprite;
		/**	 * 	 * @author Francois	 * @date 19 nov. 2010;	 */
	public class ObjectsFlagger extends Sprite {

		private var _items:Vector.<ObjectChecker>;
		private var _area:Point;
										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ObjectsFlagger</code>.		 */		public function ObjectsFlagger() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the number of items displayed.		 */		public function get length():Number { return numChildren; }		/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Populates the value object		 */
		public function populate(data:MapEntry, area:Point):void {			_area = area;
			while(numChildren > 0) {
				ObjectChecker(getChildAt(0)).unSelect();
				removeChildAt(0);			}
						if(data == null) return;			
			var objects:String = data.rawData.@i;			if(objects.length == 0 || !SharedObjectManager.getInstance().spoil) return;						var i:int, len:int, j:int, lenJ:int, indexes:Array, item:ObjectChecker, items:Array, gottenObjects:Array;			indexes = objects.split(",");			len = indexes.length;			items = [];			gottenObjects = SharedObjectManager.getInstance().getGotObjectsByArea(_area);
						for(i = 0; i < len; ++i) {				item = _items[parseInt(indexes[i])];				lenJ = gottenObjects==null? 0 : gottenObjects.length;				for(j = 0; j < lenJ; ++j) {					if(gottenObjects[j] == item.objectId) {						item.select();						break;					}				}				addChild(item);				items.push(item);			}			if(items.length > 0) PosUtils.hDistribute(items, item.width * 5 + 2, 2, 2);		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			var i:int, len:int, item:ObjectChecker, iconClass:Class;			_items = new Vector.<ObjectChecker>();			len = Constants.ITEMS+1;			for(i = 1; i < len; ++i) {				item	= new ObjectChecker(i);				item.addEventListener(Event.CHANGE, changeSelectionHandler);				_items.push(item);			}
		}

		/**		 * Called when a button's state changes		 */
		private function changeSelectionHandler(event:Event):void {			var i:int, len:int, ids:Array;
			len = numChildren;			ids = [];
			for(i = 0; i < len; ++i) {
				if(ObjectChecker(getChildAt(i)).selected) {					ids.push(ObjectChecker(getChildAt(i)).objectId);
				}			}			SharedObjectManager.getInstance().setGotObjectsOfArea(_area, ids);			DataManager.getInstance().renderMap();
		}
			}}