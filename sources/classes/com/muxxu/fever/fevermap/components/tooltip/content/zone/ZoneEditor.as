package com.muxxu.fever.fevermap.components.tooltip.content.zone {
	import by.blooddy.crypto.serialization.JSON;

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import com.muxxu.fever.fevermap.utils.IslandDrawer;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.graphics.Ground1Graphic;
	import com.muxxu.fever.graphics.Ground2Graphic;
	import com.muxxu.fever.graphics.GroundGraphic;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 3 déc. 2010;
	 */
	public class ZoneEditor extends Sprite {

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
		private var _calkBt:FeverButton;
		private var _bmd:BitmapData;
		private var _selector:Shape;
		private var _selectorIndex:int;
		private var _items:Vector.<DisplayObject>;
		private var _fr:FileReference;
		private var _bmp:Bitmap;
		private var _calk:Loader;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ZoneEditor</code>.
		 */
		public function ZoneEditor() {
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
					if(_matrix[i][j] is Array) {
						value = _matrix[i][j][1];
					}else{
						value = _matrix[i][j];
					}
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
				
				len = String(data.rawData.@e).split(",").length;
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
			try {
				_calk.unloadAndStop();
			}catch(error:Error) {
				//osef
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
			_reset		= new FeverButton(Label.getLabel("mapEditReset"));
			_calkBt		= new FeverButton(Label.getLabel("mapEditCopy"));
			_selector	= new Shape();
			_itemToName	= new Dictionary();
			_fr			= new FileReference();
			_bmd		= new BitmapData(_COLS * _CELL_SIZE + 1, _ROWS * _CELL_SIZE + 1, true, 0x055000000);
			_calk		= addChild(new Loader()) as Loader;
			_bmp		= addChild(new Bitmap(_bmd)) as Bitmap;
			
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
			displayOrder.push("Enemy15Graphic");
			
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
			displayOrder.push("GroundGraphic");
			displayOrder.push("Ground1Graphic");
			displayOrder.push("Ground2Graphic");
			displayOrder.push("WallGraphic");
			
			
			var i:int, len:int, item:GraphicButton, icon:Sprite, tf:CssTextField, iconClass:Class, py:int, px:int, maxH:int, lastTfY:int;
			len = displayOrder.length;
			_items = new Vector.<DisplayObject>();
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
					_items.push(item);
					_scrollable.content.addChild(item);
					_itemToName[item] = "com.muxxu.fever.graphics."+displayOrder[i];
					px += Math.round(item.width + 2);
				}catch(e:Error) {
					tf = _scrollable.content.addChild(new CssTextField("menuContentTitle")) as CssTextField;
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
			
			_selectorIndex = _items.length - 4;
			selectItem(_items[_selectorIndex]);
			
			py += maxH + 10;
			_scrollable.content.graphics.beginFill(0xffffff, .15);
			_scrollable.content.graphics.drawRect(0, lastTfY, _MENU_WIDTH, py - 5 - lastTfY);
			_scrollable.content.graphics.endFill();
			
			PosUtils.hCenterIn(_reset, _MENU_WIDTH);
			var margin:int = (_MENU_WIDTH - _reset.width - _calkBt.width - 10) * .5;
			_reset.x = margin;
			_calkBt.x = Math.round(_MENU_WIDTH - margin - _calkBt.width);
			_reset.y = py;
			_calkBt.y = py;
			
			_scrollable.content.addChild(_reset);
			_scrollable.content.addChild(_calkBt);
			_scrollable.content.addChild(_selector);
			
			_scrollpane.x = _CELL_SIZE * _COLS + 5;
			_scrollpane.height = _CELL_SIZE * _COLS + 15;
			_scrollpane.width = _scrollable.content.height > _scrollpane.height? _MENU_WIDTH + 20 : _MENU_WIDTH;
			_scrollpane.autoHideScrollers = true;
			_scrollpane.validate();
			
			_calk.scaleX = _calk.scaleY = _CELL_SIZE/32;
			_calk.x = _bmp.x;
			_calk.y = _bmp.y;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			_fr.addEventListener(Event.SELECT, selectFileHandler);
			_fr.addEventListener(Event.COMPLETE, loadFileCompleteHandler);
			_fr.addEventListener(IOErrorEvent.IO_ERROR, loadFileErrorHandler);
			_fr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFileErrorHandler);
			_calk.contentLoaderInfo.addEventListener(Event.COMPLETE, loadFileCompleteHandler);
			_calk.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadFileErrorHandler);
		}
		
		/**
		 * Called when the user uses the mouse's wheel.
		 */
		private function mouseWheelHandler(event:MouseEvent):void {
			_selectorIndex -= MathUtils.sign(event.delta);
			_selectorIndex = _selectorIndex % _items.length;
			if(_selectorIndex < 0) {
				_selectorIndex = _items.length + _selectorIndex;
			}
			
			selectItem(_items[_selectorIndex]);
		}
		
		/**
		 * Select an item.
		 */
		private function selectItem(item:DisplayObject):void {
			_selector.x = item.x - 2;
			_selector.y = item.y - 2;
			_selector.graphics.clear();
			_selector.graphics.lineStyle(2, 0xffff00, 1);
			_selector.graphics.drawRect(0, 0, item.width + 4, item.height + 4);
			_selector.graphics.endFill();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(Event.PASTE, pastHandler);
			stage.addEventListener(Event.COPY, copyHandler);
		}
		
		/**
		 * Called when the user pasts something
		 */
		private function pastHandler(event:Event):void {
			if(!_opened) return;
			var m:Array = JSON.decode(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String);
			if(m != null) {
				_matrix = m;
				renderGrid();
			}
		}
		
		/**
		 * Called when the users wants to copy something.
		 */
		private function copyHandler(event:Event):void {
			if(!_opened) return;
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, JSON.encode(_matrix));
		}
		
		/**
		 * Called when a key is released.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(!_opened) return;
			if(event.keyCode == Keyboard.ESCAPE) {
				_selectorIndex = _items.length - 4;
				selectItem(_items[_selectorIndex]);
			}
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(_calk.width > 0) {
				switch(event.keyCode){
					case Keyboard.Z: _calk.y --; break;
					case Keyboard.Q: _calk.x --; break;
					case Keyboard.S: _calk.y ++; break;
					case Keyboard.D: _calk.x ++; break;
					default:
				}
			}
		}
		
		/**
		 * Called when the mouse is pressed
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(_scrollable.contains(event.target as DisplayObject) && _itemToName[event.target] != null) {
				var i:int, len:int;
				len = _items.length;
				for(i = 0; i < len; ++i) {
					if(_items[i] == event.target) {
						_selectorIndex = i;
						selectItem(_items[i]);
						break;
					}
				}
				
				var clazz:Class = getDefinitionByName(_itemToName[_items[_selectorIndex]]) as Class;
				_draggedItem = new clazz();
				addChild(_draggedItem);
			}else if(mouseX < _CELL_SIZE * _COLS){
				_pressed = true;
				var px:int = Math.floor(mouseX/_CELL_SIZE);
				var py:int = Math.floor(mouseY/_CELL_SIZE);
				if(py < _ROWS && px < _COLS && px >= 0 && py >= 0) {
					var id:* = getCurrentItemName();
					var value:* = _matrix[py][px];
					if(value is Array) {
						if(isNaN(id)) _eraseMode = value.length > 1 && value[1] == id;
						else _eraseMode = value[0] == id;
					}else{
						_eraseMode = value == id;
					}
				}
			}
			addEventListener(Event.ENTER_FRAME, renderGrid);
			renderGrid();
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
					setMatrixValueAt(px, py, getCurrentItemName());
				}
				removeChild(_draggedItem);
				_draggedItem = null;
				renderGrid();
			}
		}
		
		/**
		 * Gets the currently selected item's name.
		 */
		private function getCurrentItemName():* {
			if(_items[_selectorIndex] is GroundGraphic) return 1;
			if(_items[_selectorIndex] is Ground1Graphic) return 2;
			if(_items[_selectorIndex] is Ground2Graphic) return 3;
			var name:String = _itemToName[_items[_selectorIndex]].replace(/.*\./gi, "");
			name = name.replace(/Graphic/gi, "");
			name = name.replace(/Enemy/gi, "E");
			name = name.replace(/Item/gi, "I");
			if(name == "Ground") return 1;
			if(name == "Ground1") return 2;
			if(name == "Ground2") return 3;
			return name;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function renderGrid(event:Event = null):void {
			var i:int, j:int, lenI:int, lenJ:int, clazz:Class, rect:Rectangle;
			var px:int = Math.floor(mouseX/_CELL_SIZE);
			var py:int = Math.floor(mouseY/_CELL_SIZE);
			var inGrid:Boolean = py < _ROWS && px < _COLS && px >=0 && py >= 0;
			
			var v:* = getCurrentItemName();
			//Set new value on the current cell
			if(_pressed && inGrid) { 
				var level1Values:Array = [1,2,3,"Wall","Ladder"];
				var level1:Boolean = level1Values.indexOf(v) > -1;
				var same:Boolean = false;
				if(_matrix[py][px] is Array) {
					same = _matrix[py][px][level1? 0 : 1] == v;
				}else{
					same = _matrix[py][px] == v;
				}
				if(px != _lastPx || py != _lastPy || (same && _eraseMode) || !same) {
					setMatrixValueAt(px, py, v);
					_lastPx = px;
					_lastPy = py;
				}
			}
			
			
			//RENDER THE WHOLE GRID
			if(event == null) {
				lenI = _matrix.length;
				for(i = 0; i < lenI; ++i) {
					lenJ = _matrix[i].length;
					for(j = 0; j < lenJ; ++j) {
						IslandDrawer.drawItemToGrid(_bmd, _matrix[i][j], j, i, _CELL_SIZE);
					}
				}
			}else if(inGrid){
				IslandDrawer.drawItemToGrid(_bmd, _matrix[py][px], px, py, _CELL_SIZE);
			}
			
			if(_draggedItem != null) {
				PosUtils.hCenterIn(_draggedItem, mouseX * 2);
				PosUtils.vCenterIn(_draggedItem, mouseY * 2);
			}
			_somethingHasChanged = true;
			
//			if(event == null) {
				//DRAW THE GRID'S WIREFRAME
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
//			}
		}
		
		/**
		 * Sets the value of a matrix entry
		 */
		private function setMatrixValueAt(px:int, py:int, v:*):void {
			var level1Values:Array = [1,2,3,"Wall","Ladder"];
			var level1:Boolean = level1Values.indexOf(v) > -1;
			if(v == 0) {
				_matrix[py][px] = 0;
				return;
			}
			
			if(_eraseMode) {
				if(_matrix[py][px] is Array) {
					_matrix[py][px] = level1? _matrix[py][px][1] : _matrix[py][px][0];
				}else{
					_matrix[py][px] = 0;
				}
				return;
			}else if(_matrix[py][px] == 0) {
				_matrix[py][px] = v;
				return;
			}
			
			if(_matrix[py][px] is Array) {
				_matrix[py][px][level1? 0 : 1] = v;
			}else{
				//If current value is level 1
				if(level1Values.indexOf(_matrix[py][px]) > -1) {
					if(level1Values.indexOf(v) > -1) {
						_matrix[py][px] = v;
					} else {
						_matrix[py][px] = [_matrix[py][px], v];
					}
				}else{
					if(level1Values.indexOf(v) > -1) {
						_matrix[py][px] = [v, _matrix[py][px]];
					} else {
						_matrix[py][px] = v;
					}
				}
			}
		}
		
		/**
		 * Called when reset button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _reset) {
				reset();
			}else if(event.target == _calkBt) {
				_fr.browse([new FileFilter("image", "*.png;*.jpg;*.jpeg")]);
			}
		}
		
		
		
		
		//__________________________________________________________ FILE LOADING
		
		/**
		 * Called when a file is selected.
		 */
		private function selectFileHandler(event:Event):void {
			_fr.load();
		}
		
		/**
		 * Called when the file loading completes.
		 */
		private function loadFileCompleteHandler(event:Event):void {
			if(event.target == _fr) {
				_calk.loadBytes(_fr.data);
			}else{
				_calk.x = Math.round(((_CELL_SIZE*_COLS - _calk.width) * .5)/_CELL_SIZE) * 16;
				_calk.y = Math.round(((_CELL_SIZE*_ROWS - _calk.height) * .5)/_CELL_SIZE) * 16;
			}
		}
		
		/**
		 * Called if file loading fails
		 */ 
		private function loadFileErrorHandler(event:ErrorEvent):void {
		}
		
	}
}