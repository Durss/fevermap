package com.muxxu.fever.fevermap.components.tooltip.content.zone {
	import by.blooddy.crypto.serialization.JSON;

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.graphics.GroundGraphic;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Not used anymore.? Oo
	 * 
	 * @author Francois
	 * @date 3 déc. 2010;
	 */
	public class ZoneMap extends Sprite {

		private const _COLS:int = 20;
		private const _ROWS:int = 20;
		private const _CELL_SIZE:int = 16;
		private const _MENU_WIDTH:int = 170;
		
		private var _matrix:Array;
		private var _pressed:Boolean;
		private var _lastPx:int;
		private var _lastPy:int;
		private var _eraseMode:Boolean;
		private var _itemToName:Dictionary;
		private var _draggedItem:DisplayObject;
		private var _enemies:Array;
		private var _objects:Array;
		private var _somethingHasChanged:Boolean;
		private var _opened:Boolean;
		private var _scrollpane:ScrollPane;
		private var _scroller:FeverScrollBar;
		private var _scrollable:ScrollableDisplayObject;
		private var _reset:FeverButton;
		private var _bmd:BitmapData;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ZoneMap</code>.
		 */
		public function ZoneMap() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the grid's data as JSON string.
		 */
		public function get data():String { return JSON.encode(_matrix); }
		
		/**
		 * Gets the enemies.
		 */
		public function get enemies():Array { computeData(); return _enemies; }
		
		/**
		 * Gets the objects.
		 */
		public function get objects():Array { computeData(); return _objects; }
		
		/**
		 * Gets the opened state.
		 */
		public function get opened():Boolean { return _opened; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Computes the data.
		 * (used to have only one double loop instead of two for items AND enemies
		 */
		public function computeData():void {
			if(!_somethingHasChanged) return;
			var i:int, j:int, value:String;
			_enemies = [];
			_objects = [];
			for(i = 0; i < _ROWS; ++i) {
				for(j = 0; j < _COLS; ++j) {
					value = _matrix[i][j];
					if(value.search("E") == 0) {
						_enemies.push(value.replace(/E([0-9]+).*/gi, "$1"));
					}else if(value.search("I") == 0) {
						_objects.push(value.replace(/I([0-9]+).*/gi, "$1"));
						_objects[_objects.length-1] = parseInt(_objects[_objects.length-1]) - 1;
					}
				}
			}
			_somethingHasChanged = false;
		}
		
		/**
		 * Populates the component
		 */
		public function populate(data:MapEntry):void {
			var str:String = data.rawData.@data;
			if(str.length > 0) {
				_matrix = JSON.decode(str);
				renderGrid();
			}else{
				//Retro compatibility management.
				reset();
				var i:int, len:int, chunks:Array;
				chunks = data.rawData.@i.split(",");
				len = (chunks.length == 1 && chunks[0].length == 0)? 0 : chunks.length;
				for(i = 0; i < len; ++i) {
					_matrix[i][0] = "I"+(parseInt(chunks[i])+1);
				}
				
				len = String(data.rawData.@e).split(",").length + 1;
				var col:int = 1;
				for(i = 0; i < len; ++i) {
					if(i%_COLS == 0 && i > 0) col ++;
					_matrix[i%_COLS][col] = "E1";
				}
				
				renderGrid();
			}
		}
		
		/**
		 * Populates with a revision
		 */
		public function populateRevision(data:Revision):void {
			if(data.matrix.length > 0 ) {
				_matrix = JSON.decode(data.matrix);
				renderGrid();
			}else{
				reset();
				var i:int, len:int, chunks:Array;
				chunks = data.items.split(",");
				len = (chunks.length == 1 && chunks[0].length == 0)? 0 : chunks.length;
				for(i = 0; i < len; ++i) {
					_matrix[i][0] = "I"+(parseInt(chunks[i])+1);
				}
				
				len = data.enemies.length;
				for(i = 0; i < len; ++i) {
					_matrix[i][1] = "E1";
				}
				
				renderGrid();
			}
		}
		
		/**
		 * Resets the form
		 */
		public function reset():void {
			var i:int, j:int;
			_matrix = new Array(_ROWS);
			for(i = 0; i < _ROWS; ++i) {
				_matrix[i] = new Array(_COLS);
				for(j = 0; j < _COLS; ++j) {
					_matrix[i][j] = 0;
				}
			}
			renderGrid();
		}

		/**
		 * Opens the form
		 */
		public function open():void {
			_opened = true;
		}
		
		/**
		 * Closes the form
		 */
		public function close():void {
			_opened = false;
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_scroller	= new FeverScrollBar();
			_scrollable	= new ScrollableDisplayObject();
			_scrollpane	= addChild(new ScrollPane(_scrollable, _scroller)) as ScrollPane;
			_reset		= addChild(new FeverButton(Label.getLabel("mapEditReset"))) as FeverButton;
			_itemToName	= new Dictionary();
			
			var displayOrder:Array = [];
			displayOrder.push(Label.getLabel("mapEditEnemies"));
			displayOrder.push("Enemy1Graphic");
			displayOrder.push("Enemy9Graphic");
			displayOrder.push("Enemy5Graphic");
			displayOrder.push("Enemy2Graphic");
			displayOrder.push("Enemy4Graphic");
			displayOrder.push("Enemy8Graphic");
			displayOrder.push("Enemy12Graphic");
			displayOrder.push("Enemy6Graphic");
			displayOrder.push("Enemy3Graphic");
			displayOrder.push("Enemy14Graphic");
			displayOrder.push("Enemy16Graphic");
			displayOrder.push("Enemy7Graphic");
			displayOrder.push("Enemy10Graphic");
			displayOrder.push("Enemy11Graphic");
			
			displayOrder.push(Label.getLabel("mapEditMultipleObjects"));
			for(i = 1; i < 12; ++i) displayOrder.push("Item"+i+"Graphic");
			
			displayOrder.push(Label.getLabel("mapEditUniqueObjects"));
			for(i = 12; i < 34; ++i) displayOrder.push("Item"+i+"Graphic");
			
			displayOrder.push(Label.getLabel("mapEditSpecialObjects"));
			for(i = 34; i < 41; ++i) displayOrder.push("Item"+i+"Graphic");
			displayOrder.push("Item44Graphic");
			displayOrder.push("Item45Graphic");
			
			displayOrder.push(Label.getLabel("mapEditOther"));
			for(i = 41; i < 44; ++i) displayOrder.push("Item"+i+"Graphic");
			displayOrder.push("RainbowGraphic");
			displayOrder.push("LadderGraphic");
			
			var i:int, len:int, item:GraphicButton, icon:Sprite, tf:CssTextField, iconClass:Class, py:int, px:int, maxH:int, lastTfY:int;
			len = displayOrder.length;
			for(i = 0; i < len; ++i) {
				try {
					iconClass	= getDefinitionByName("com.muxxu.fever.graphics."+displayOrder[i]) as Class;
					icon		= new iconClass() as Sprite;
					item		= new GraphicButton(createRect(), icon);
					item.filters = [new GlowFilter(0,.5,1.1,1.1,10,2)];
					if(px + item.width > _MENU_WIDTH) {
						px = 8;
						py += maxH + 2;
						maxH = 0;
					}
					item.x		= px;
					item.y		= py;
					maxH		= Math.max(maxH, item.height);
					_scrollable.addChild(item);
					_itemToName[item] = "com.muxxu.fever.graphics."+displayOrder[i];
					px += Math.round(item.width + 2);
				}catch(e:Error) {
					tf = _scrollable.addChild(new CssTextField("menuContentTitle")) as CssTextField;
					tf.text = displayOrder[i];
					tf.background = true;
					tf.backgroundColor = 0;
					tf.width = _MENU_WIDTH;
					py += i==0? 0 : maxH + 15;
					
					if(i > 0) {
						_scrollable.content.graphics.beginFill(0xffffff, .15);
						_scrollable.content.graphics.drawRect(0, lastTfY, _MENU_WIDTH, py - 10 - lastTfY);
						_scrollable.content.graphics.endFill();
					}
					
					lastTfY = py;
					tf.y = py;
					maxH = 0;
					px = 8;
					py += Math.round(tf.height + 2);
				}
			}
			
			py += maxH + 10;
			_scrollable.content.graphics.beginFill(0xffffff, .15);
			_scrollable.content.graphics.drawRect(0, lastTfY, _MENU_WIDTH, py - 5 - lastTfY);
			_scrollable.content.graphics.endFill();
			
			PosUtils.hCenterIn(_reset, _MENU_WIDTH);
			_reset.y = py;
			_scrollable.addChild(_reset);
			
			_scrollpane.x = _CELL_SIZE * _COLS + 5;
			_scrollpane.height = _CELL_SIZE * _COLS + 15;
			_scrollpane.width = _scrollable.content.height > _scrollpane.height? _MENU_WIDTH + 20 : _MENU_WIDTH;
			_scrollpane.autoHideScrollers = true;
			_scrollpane.validate();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_reset.addEventListener(MouseEvent.CLICK, clickResetHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * Called when the mouse is released.
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			_pressed = false;
			removeEventListener(Event.ENTER_FRAME, renderGrid);
			if(_draggedItem != null) {
				var px:int = Math.floor(mouseX/_CELL_SIZE);
				var py:int = Math.floor(mouseY/_CELL_SIZE);
				if(py < _ROWS && px < _COLS && px >=0 && py >= 0) {
					var name:String = getQualifiedClassName(_draggedItem).replace(/^.*::/gi, "");
					name = name.replace(/Graphic/gi, "");
					name = name.replace(/Enemy/gi, "E");
					name = name.replace(/Item/gi, "I");
					_matrix[py][px] = name;
				}
				removeChild(_draggedItem);
				_draggedItem = null;
				renderGrid();
			}
		}
		
		/**
		 * Called when the mouse is pressed
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(_scrollable.contains(event.target as DisplayObject) && _itemToName[event.target] != null) {
				var clazz:Class = getDefinitionByName(_itemToName[event.target]) as Class;
				_draggedItem = new clazz();
				addChild(_draggedItem);
			}else if(mouseX < _CELL_SIZE * _COLS){
				_pressed = true;
				var px:int = Math.floor(mouseX/_CELL_SIZE);
				var py:int = Math.floor(mouseY/_CELL_SIZE);
				if(py < _ROWS && px < _COLS && px >=0 && py >= 0) {
					_eraseMode = _matrix[py][px] > 0;
				}
			}
			addEventListener(Event.ENTER_FRAME, renderGrid);
			renderGrid();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function renderGrid(event:Event = null):void {
			var i:int, j:int, lenI:int, lenJ:int, clazz:Class, rect:Rectangle;
			if(event == null) {
				_bmd = new BitmapData(_COLS * _CELL_SIZE + 1, _ROWS * _CELL_SIZE + 1, true, 0x055000000);
			
				//DRAW THE GRID
				rect = new Rectangle();
				rect.x = 0;
				rect.width = _COLS * _CELL_SIZE;
				rect.height = 1;
				for(i = 0; i < _ROWS + 1; ++i) {
					rect.y = i * _CELL_SIZE;
					_bmd.fillRect(rect, 0xffffffff);
				}
				
				rect.y = 0;
				rect.width = 1;
				rect.height = _ROWS * _CELL_SIZE;
				for(i = 0; i < _COLS + 1; ++i) {
					rect.x = i * _CELL_SIZE;
					_bmd.fillRect(rect, 0xffffffff);
				}
				//END GRID DRAWING
			}
			
			
			var px:int = Math.floor(mouseX/_CELL_SIZE);
			var py:int = Math.floor(mouseY/_CELL_SIZE);
			var v:int = _eraseMode? 0 : 1;
			//Set new value on the current cell
			if(_pressed && (px != _lastPx || py != _lastPy || _matrix[py][px] != v) && py < _ROWS && px < _COLS && px >=0 && py >= 0) {
				_matrix[py][px] = v;
				_lastPx = px;
				_lastPy = py;
			}
			
			
			//RENDER THE WHOLE GRID
			if(event == null) {
				lenI = _matrix.length;
				for(i = 0; i < lenI; ++i) {
					lenJ = _matrix[i].length;
					for(j = 0; j < lenJ; ++j) {
						drawItemToGrid(i, j);
					}
				}
			}else if(py < _ROWS && px < _COLS && px >=0 && py >= 0){
				drawItemToGrid(px, py);
			}
			
			if(_draggedItem != null) {
				PosUtils.hCenterIn(_draggedItem, mouseX * 2);
				PosUtils.vCenterIn(_draggedItem, mouseY * 2);
			}
			
			graphics.clear();
			graphics.beginBitmapFill(_bmd);
			graphics.drawRect(0, 0, _bmd.width, _bmd.height);
			graphics.endFill();
			_somethingHasChanged = true;
		}
		
		/**
		 * Draws an item to the grid.
		 */
		private function drawItemToGrid(px:int, py:int):void {
			var m:Matrix, item:DisplayObject, value:String, clazz:Class, scale:Number;
			value = _matrix[py][px];
			if(value != "0") {
				item = new GroundGraphic();
				scale = (_CELL_SIZE-1) / item.width;
				m = new Matrix();
				m.scale(scale, scale);
				m.translate(px * _CELL_SIZE + 1, py * _CELL_SIZE + 1);
				_bmd.draw(item, m);
				
				if(value != "1") {
					name = value;
					name = name.replace(/E([0-9]+)/gi, "Enemy$1");
					name = name.replace(/I([0-9]+)/gi, "Item$1");
					clazz = getDefinitionByName("com.muxxu.fever.graphics." + name + "Graphic") as Class;
					item = new clazz();
					m = new Matrix();
					scale	= Math.min((_CELL_SIZE-1) / item.width, (_CELL_SIZE-1) / item.height);
					m.scale(scale, scale);
					m.translate(px * _CELL_SIZE + 1 + (_CELL_SIZE - item.width * scale) * .5, py * _CELL_SIZE + 1 + (_CELL_SIZE - item.height * scale) * .5);
					_bmd.draw(item, m);
				}
			}
		}
		
		/**
		 * Called when reset button is clicked
		 */
		private function clickResetHandler(event:MouseEvent):void {
			reset();
		}
		
	}
}