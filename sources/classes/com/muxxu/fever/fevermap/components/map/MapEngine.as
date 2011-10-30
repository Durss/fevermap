package com.muxxu.fever.fevermap.components.map {
	import gs.TweenLite;

	import com.muxxu.fever.fevermap.components.map.icons.MapIconMapPattern;
	import com.muxxu.fever.fevermap.components.tooltip.ToolTip;
	import com.muxxu.fever.fevermap.components.tooltip.content.TTZoneContent;
	import com.muxxu.fever.fevermap.vo.ToolTipMessage;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.nurun.components.invalidator.Invalidator;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.core.lang.Disposable;
	import com.nurun.utils.math.MathUtils;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;


	[Event(name="mapEngineDataNeeded", type="com.muxxu.fever.fevermap.components.map.MapEngineEvent")]

	/**	 * Displays and manages a MAP.	 * 	 * @author  Francois	 */
	public class MapEngine extends Sprite implements Validable, Disposable {

		protected const _DISABLE_TT_ALPHA:Number = 1;
		protected var _cellSize:int = 64;
		protected var _width:int;
		protected var _height:int;
		protected var _pattern:BitmapData;
		protected var _iconsCtn:Sprite;
		protected var _dragOffset:Point;
		protected var _posOffset:Point;
		protected var _px:Number;
		protected var _py:Number;
		protected var _pressed:Boolean;
		protected var _disableLayer:Sprite;
		protected var _spin:SpinGraphic;
		protected var _currentArea:Rectangle;
		protected var _tooltip:ToolTip;
		protected var _ttContent:TTZoneContent;
		protected var _ttMessage:ToolTipMessage;
		protected var _square:Shape;
		protected var _holder:Sprite;
		protected var _ttLocked:Boolean;
		protected var _entriesCoords:Array;
		protected var _lastTTCoords:Point;
		protected var _zoomLevel:int;
		protected var _iconToData:Dictionary;
		protected var _entries:Vector.<MapEntry>;
		protected var _coeff:Number;
		protected var _isMouseOver:Boolean;
		protected var _invalidator:Invalidator;
		protected var _enabled:Boolean;
		protected var _pxCenter:Number;
		protected var _pyCenter:Number;
		protected var _lastTTPos:Point;
		protected var _upPressed:Boolean;
		protected var _downPressed:Boolean;
		protected var _leftPressed:Boolean;
		protected var _rightPressed:Boolean;
		protected var _lastUpdateTime:Number;
		protected var _zoneToOpen:Point;
		protected var _container:Sprite;
		protected var _underlay:Sprite;
		protected var _overlay:Sprite;


		/* *********** *		 * CONSTRUCTOR *		 * *********** */
		/**		 * Creates an instance of <code>MapEngine</code>.		 */
		public function MapEngine() {
			initialize();
		}


		/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */
		/**		 * Sets the component's width without simply scaling it.		 */
		override public function set width(value:Number):void {
			_width = value;
			_invalidator.invalidate();
		}


		/**		 * Sets the component's height without simply scaling it.		 */
		override public function set height(value:Number):void {
			_height = value;
			render(true);
			_invalidator.invalidate();
		}


		/**		 * Gets the virtual component's width.		 */
		override public function get width():Number {
			return _width;
		}


		/**		 * Gets the virtual component's height.		 */
		override public function get height():Number {
			return _height;
		}


		/**		 * Gets the rolled over cell's coordinates.		 */
		public function get overCell():MapEntry {
			var pos:Point = overCoordinates;
			return _entriesCoords[pos.x + "_" + pos.y];
		}


		/**		 * Gets the rolled over cell's coordinates.		 */
		public function get overCoordinates():Point {
			var res:Point = new Point();
			res.x = Math.floor((-_pxCenter + mouseX + 1) * _coeff);
			res.y = Math.floor((-_pyCenter + mouseY + 1) * _coeff);
			return res;
		}
			
		/**
		 * Gets the current zoom level
		 */
		public function get zoomLevel():int { return _zoomLevel; }
			
		/**
		 * Sets the current zoom level
		 */
		public function set zoomLevel(value:int):void {
			_zoomLevel = value;
			wheelHandler(new MouseEvent(MouseEvent.MOUSE_WHEEL));
		}
		
		public function get posX():Number { return _px; }
		public function get posY():Number { return _py; }
		public function set posX(value:Number):void { _px = value; }
		public function set posY(value:Number):void { _py = value; }
		
		


		/* ****** *		 * PUBLIC *		 * ****** */
		/**		 * @inheritDoc		 */
		public function validate():void {
			_invalidator.flagAsValidated();
			render(true);
			checkForLoading();
		}
		
		/**
		 * initializes the map
		 */
		public function init(zoom:int, pos:Point):void {
			_zoomLevel = zoom;
			_cellSize = _zoomLevel == 5? 350 : _zoomLevel * 16;
			_coeff = 1 / _cellSize;
			centerOn(pos);
		}


		/**		 * Populates the map with a vector of <code>MapEntry</code> value objects.		 * 		 * @param data		the data to display in the map.		 * @param dataRect	the loaded data rectangle. If the user drags the map outside of this rect, new data will have to be loaded.		 */
		public function populate(data:Vector.<MapEntry>, dataRect:Rectangle):void {
			var i:int, len:int, icon:DisplayObject, entry:MapEntry;
//			_ttLocked = false;
			if(_entries != null) {
				len = _entries.length;
				for(i = 0; i < len; ++i) {
					_entries[i].dispose();
					_entries[i].icon.removeEventListener(MapEntryEvent.UPDATE, mapEntryUpdateHandler);
				}
			}
			_entries = new Vector.<MapEntry>();
			_entriesCoords = [];
			_iconToData = new Dictionary();
			
			while(_iconsCtn.numChildren > 0) _iconsCtn.removeChildAt(0);
			
			len = data.length;
			for(i = 0; i < len; ++i) {
				entry = data[i];
				icon = _iconsCtn.addChild(entry.icon as DisplayObject);
				icon.x = entry.x * _cellSize;
				icon.y = entry.y * _cellSize;
				_entriesCoords[entry.x + "_" + entry.y] = entry;
				_iconToData[icon] = entry;
				_entries.push(entry);
				icon.addEventListener(MapEntryEvent.UPDATE, mapEntryUpdateHandler);
			}
			_currentArea = dataRect;
			
			wheelHandler();
			
			if(_zoneToOpen != null) {
				openZone(_zoneToOpen);
				_zoneToOpen = null;
			}
		}


		/**		 * Centers the map on a specific point		 */
		public function centerOn(pos:Point):void {
			_px = -pos.x * _cellSize - _cellSize * .5;
			_py = -pos.y * _cellSize - _cellSize * .5;
			render(true);
			checkForLoading();
		}


		/**		 * Gets a bitmap data of the center.		 * 		 * @param w	number of zone in width to capture.		 * @param h number of zone in height to capture.		 */
		public function getBmdOfCenter(w:int, h:int):BitmapData {
			var bmd:BitmapData = new BitmapData(w * _cellSize + 1, h * _cellSize + 1, true, 0);
			var m:Matrix = new Matrix();
			var tx:Number = -Math.round(_width * .5 * _coeff) * _cellSize + Math.floor(w * .5) * _cellSize;
			var ty:Number = -Math.round(_height * .5 * _coeff) * _cellSize + Math.floor(h * .5) * _cellSize;
			m.translate(tx, ty);
			removeChild(_tooltip);
			bmd.draw(this, m);
			addChild(_tooltip);
			return bmd;
		}


		/**		 * Enables rendering		 */
		public function enable(forceLoad:Boolean = false):void {
			_enabled = true;
			mouseChildren = true;
			if(!_ttLocked) {
				TweenLite.to(_disableLayer, .5, {autoAlpha:0});
			}
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if(forceLoad) {
				validate();
			}
		}


		/**		 * Disables rendering		 */
		public function disable():void {
			_enabled = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}


		/**		 * Removes an entry from the map.		 */
		public function removeEntry(x:int, y:int):void {
			var i:int, len:int, entry:MapEntry;
			len = _entries.length;
			delete _entriesCoords[x + "_" + y];
			for(i = 0; i < len; ++i) {
				entry = _entries[i];
				if(entry.x == x && entry.y == y) {
					_entries.splice(i, 1)[0];
					_iconsCtn.removeChild(entry.icon as DisplayObject);
					delete _iconToData[entry.icon];
					len--;
					i--;
				}
			}
		}


		/**		 * Closes the tooltip.		 */
		public function closeToolTip():void {
			_ttLocked = false;
			_tooltip.alpha = _DISABLE_TT_ALPHA;
			_tooltip.mouseChildren = false;
			_tooltip.close();
		}


		/**
		 * Updates the map.
		 */
		public function update(force:Boolean = false):void {
			_lastUpdateTime = getTimer();
			wheelHandler(null, 0, force);
		}
		
		/**
		 * Opens the tooltip of specifi zone
		 */
		public function openZone(pos:Point):void {
			if(_entriesCoords[pos.x + "_" + pos.y] == undefined) {
				_zoneToOpen = pos;
				centerOn(pos);
				return;
			}
			centerOn(pos);
			_ttLocked = true;
			_tooltip.x = stage.stageWidth * .5;
			_tooltip.y = stage.stageHeight * .5;
			_ttContent.populate(pos.x, pos.y, _entriesCoords[pos.x + "_" + pos.y]);
			_tooltip.mouseChildren = true;
			_tooltip.mouseEnabled = true;
			_ttContent.displayFull();
			_spin.visible = false;
			TweenLite.to(_disableLayer, .5, {autoAlpha:1});
			_lastTTPos = new Point(_tooltip.x, _tooltip.y + _tooltip.height * .65);
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			var i:int, len:int;
			len = _entries.length;
			for(i = 0; i < len; ++i) {
				_entries[i].icon.removeEventListener(MapEntryEvent.UPDATE, mapEntryUpdateHandler);
				_entries[i].dispose();
				if(_iconsCtn.contains(_entries[i].icon as DisplayObject)) {
					_iconsCtn.removeChild(_entries[i].icon as DisplayObject);
				}
			}
			
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			removeEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOutOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutOverHandler);
			removeEventListener(MouseEvent.ROLL_OUT, mouseOutOverHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_tooltip.removeEventListener(Event.CLOSE, closeTooltipHandler);
			
			_pattern.dispose();
			_tooltip.dispose();
			_entriesCoords = null;
			_lastTTCoords = null;
			_iconToData = null;
			_entries = null;
			_invalidator.dispose();
			_invalidator = null;
		}
		


		/* ******* *		 * protected *		 * ******* */
		/**		 * Initializes the class.		 */
		protected function initialize():void {
			_invalidator = new Invalidator(this);
			_container = new Sprite();
			_underlay = _container.addChild(new Sprite()) as Sprite;
			_iconsCtn = _container.addChild(new Sprite()) as Sprite;
			_overlay = _container.addChild(new Sprite()) as Sprite;
			
			_ttContent = new TTZoneContent(false);
			_ttMessage = new ToolTipMessage(_ttContent, null);
			_entries = new Vector.<MapEntry>();
			_holder = addChild(new Sprite()) as Sprite;
			_square = addChild(new Shape()) as Shape;
			_disableLayer = addChild(new Sprite()) as Sprite;
			_tooltip = addChild(new ToolTip()) as ToolTip;
			_spin = _disableLayer.addChild(new SpinGraphic()) as SpinGraphic;
			_px = 0;
			_py = 0;
			_zoomLevel = 4;
			_cellSize = _zoomLevel == 5? 350 : _zoomLevel * 16;
			_coeff = 1 / _cellSize;
			_dragOffset = new Point(0,0);
			_tooltip.open(_ttMessage);
			_tooltip.x = -100000; // I know... quite dirty
			
			var src:MapIconMapPattern = new MapIconMapPattern();
			src.setImageByZoomLevel(_zoomLevel);
			_pattern = new BitmapData(src.width, src.height, true, 0);
			_pattern.draw(src);

			mouseChildren = false;
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOutOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseOutOverHandler);
			_tooltip.addEventListener(Event.CLOSE, closeTooltipHandler);
		}
		
		/**
		 * Called when an entry is validated
		 */
		protected function mapEntryUpdateHandler(event:MapEntryEvent):void {
			_invalidator.invalidate();
		}


		/**
		 * Called when the tooltip is closed.
		 */
		protected function closeTooltipHandler(event:Event):void {
			_ttLocked = false;
//			_tooltip.alpha = _DISABLE_TT_ALPHA;
//			_tooltip.mouseChildren = false;
			_tooltip.open(_ttMessage);
			TweenLite.to(_disableLayer, .25, {autoAlpha:0});
		}


		/**		 * Called when the map is rolled over or rolled out.		 */
		protected function mouseOutOverHandler(event:MouseEvent):void {
			_isMouseOver = true;
			//TODO check if the last condition isn't source of problems. Used to
			//get mouse wheel not setting _ttLocked to false in the render method.
			if(event.type == MouseEvent.ROLL_OUT && event.target == this && !_ttLocked) {
				_isMouseOver = false;
			}
		}


		/**		 * Called when the mouse's wheel is used.		 */
		protected function wheelHandler(event:MouseEvent = null, sign:int = 0, force:Boolean = false):void {
			if((!_enabled && event != null) && !force || _ttContent.editMode) return;
			var oldZL:int = _zoomLevel;
//			if(!_ttLocked) {
				if((event != null && event.delta != 0) || sign != 0) {
					_zoomLevel += (event == null)? sign : MathUtils.sign(event.delta);
					_zoomLevel = MathUtils.restrict(_zoomLevel, 1, 5);
					if(oldZL == _zoomLevel) return;
					dispatchEvent(new MapEngineEvent(MapEngineEvent.ZOOM_CHANGED));
				}
				
				var exSize:int = _cellSize;
				_cellSize = _zoomLevel == 5? 350 : _zoomLevel * 16;
				_coeff = 1 / _cellSize;
				moveCoeff = _cellSize / exSize;
				_px *= moveCoeff;
				_py *= moveCoeff;
//			}
			
			if(oldZL != _zoomLevel && _zoomLevel == 5) {
				checkForLoading(true);
				return;
			}
			
			if(event == null || _zoomLevel < 5) {
				_square.graphics.clear();
				_square.graphics.lineStyle(1);
				_square.graphics.drawRect(0, 0, _cellSize, _cellSize);
				var src:MapIconMapPattern = new MapIconMapPattern();
				src.setImageByZoomLevel(_zoomLevel);
				_pattern = new BitmapData(src.width, src.height, true, 0);
				_pattern.draw(src);
				var i:int, len:int, icon:DisplayObject, moveCoeff:Number, entry:MapEntry;
				len = _entries.length;
				for(i = 0; i < len; ++i) {
					entry = _entries[i];
					icon = entry.icon as DisplayObject;
					icon.x = entry.x * _cellSize;
					icon.y = entry.y * _cellSize;
					entry.delayBuild(i/30, _zoomLevel, _lastUpdateTime, force);
				}
				renderLayer();
//				_px *= moveCoeff;
//				_py *= moveCoeff;
				render(true);
			}
			if(event != null) {
				checkForLoading(_zoomLevel == 5);
			}
		}

		/**
		 * Called when underlay and overlay need to be rendered
		 */
		protected function renderLayer():void {
			//To override
		}


		/**		 * Resizes and replaces the elements.		 */
		protected function render(resize:Boolean = false):void {
			if(_width < 1 || _height < 1 || !_enabled) return;
			if(resize) {
				_disableLayer.graphics.clear();
				_disableLayer.graphics.beginFill(0, .6);
				_disableLayer.graphics.drawRect(0, 0, _width, _height);
				_spin.x = _width * .5;
				_spin.y = _height * .5;
			}

//			if(_isMouseOver && mouseX < _width && mouseY < _height && mouseX > 0 && mouseY > 0) {
			_square.visible = !_ttLocked;
			if(!_ttLocked) {
				var moduloX:Number = _px % _cellSize;
				var moduloY:Number = _py % _cellSize;
				var px:Number = Math.floor((mouseX - moduloX) * _coeff) * _cellSize + moduloX;
				var py:Number = Math.floor((mouseY - moduloY) * _coeff) * _cellSize + moduloY;
				_square.x = px;
				_square.y = py;
				
				px = Math.floor((-_pxCenter + mouseX + 1) * _coeff);
				py = Math.floor((-_pyCenter + mouseY + 1) * _coeff);
				if((_lastTTCoords == null || _lastTTCoords.x != px || _lastTTCoords.y != py) && _entriesCoords != null) {
					_lastTTCoords = new Point(px, py);
					_ttContent.populate(px, py, _entriesCoords[px + "_" + py]);
					_tooltip.mouseEnabled = false;
					_tooltip.mouseChildren = false;
				}
				_lastTTPos = new Point(mouseX, mouseY);
			}else{
				_lastTTPos = new Point(stage.stageWidth * .5, stage.stageHeight * .5 + _tooltip.height * .5);
			}
//			} else {
//				if(_ttLocked) {
//					_ttLocked = false;
//					_spin.visible = true;
//					_disableLayer.alpha = 0;
//					_disableLayer.visible = false;
//				}
//				_square.visible = false;
//				_ttLocked = false;
//				_tooltip.alpha = _DISABLE_TT_ALPHA;
//				_tooltip.mouseEnabled = false;
//				_tooltip.mouseChildren = false;
//			}

			_pxCenter = _px + Math.round(_width * .5 * _coeff) * _cellSize + 1;
			_pyCenter = _py + Math.round(_height * .5 * _coeff) * _cellSize + 1;
			if(_pressed || resize || _upPressed || _downPressed || _leftPressed || _rightPressed) {
				var m:Matrix = new Matrix();
				m.tx = _px % _cellSize;
				m.ty = _py % _cellSize;
				_holder.graphics.clear();
				_holder.graphics.beginBitmapFill(_pattern, m);
				_holder.graphics.drawRect(0, 0, _width, _height);
				_holder.graphics.endFill();
				var bmd:BitmapData = new BitmapData(_width, _height, true, 0);
				m = new Matrix();
				m.translate(_pxCenter, _pyCenter);
				bmd.draw(_container, m);
				_holder.graphics.beginBitmapFill(bmd);
				_holder.graphics.drawRect(0, 0, _width, _height);
				_holder.graphics.endFill();
			}

			if(_lastTTPos != null) {
				_tooltip.x = Math.round(_lastTTPos.x - _tooltip.width * .5);
				_tooltip.y = Math.round(_lastTTPos.y - _tooltip.height - 10);
				if(!_ttLocked && _lastTTPos.y - _tooltip.height < 100) {
					_tooltip.y = _lastTTPos.y + 20;
				}
			}
		}


		/**		 * Checks if data need to be loaded.		 */
		protected function checkForLoading(force:Boolean = false):void {
			if(!_enabled) return;
			var zoneW:int = Math.round(_width * _coeff);
			var zoneH:int = Math.round(_height * _coeff);
			var marginX:Number = _zoomLevel ==5? 3 : 7;
			var marginY:Number = _zoomLevel ==5? 3 : 7;
			var rect:Rectangle = new Rectangle();
			rect.left = Math.round(-_pxCenter * _coeff);
			rect.top = Math.round(-_pyCenter * _coeff);
			rect.width = zoneW;
			rect.height = zoneH;
			if(_currentArea == null || rect.x < _currentArea.left || rect.y < _currentArea.top || rect.x + rect.width > _currentArea.x + _currentArea.width || rect.y + rect.height > _currentArea.y + _currentArea.height || force) {
				rect.left -= marginX;
				rect.top -= marginY;
				rect.width += marginX;
				rect.height += marginY;
				_spin.visible = true;
				TweenLite.to(_disableLayer, .5, {autoAlpha:1});
				mouseChildren = false;
				_currentArea = rect;
				dispatchEvent(new MapEngineEvent(MapEngineEvent.DATA_NEEDED, rect));
			}
		}


		/**		 * Called when the stage is available.		 */
		protected function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keUpHandler);
		}


		/**
		 * Called when a key is released.	
		 */
		protected function keyDownHandler(event:KeyboardEvent):void {
			if(event.target is TextField) return;
			if(event.keyCode == Keyboard.UP) _upPressed = true;
			if(event.keyCode == Keyboard.DOWN) _downPressed = true;
			if(event.keyCode == Keyboard.LEFT) _leftPressed = true;
			if(event.keyCode == Keyboard.RIGHT) _rightPressed = true;
		}


		/**
		 * Called when a key is pressed.
		 */
		protected function keUpHandler(event:KeyboardEvent):void {
			if(event.target is TextField) return;
			if(_upPressed || _downPressed || _leftPressed || _rightPressed) checkForLoading();
			
			if(event.keyCode == Keyboard.UP) _upPressed = false;
			if(event.keyCode == Keyboard.DOWN) _downPressed = false;
			if(event.keyCode == Keyboard.LEFT) _leftPressed = false;
			if(event.keyCode == Keyboard.RIGHT) _rightPressed = false;
			if(event.keyCode == Keyboard.NUMPAD_ADD) {
				wheelHandler(null, 1);
				checkForLoading();
			}
			if(event.keyCode == Keyboard.NUMPAD_SUBTRACT){
				wheelHandler(null, -1);
				checkForLoading();
			}
		}


		/**		 * Called on ENTER_FRAME event.		 */
		protected function enterFrameHandler(event:Event):void {
			if(_pressed) {
				_px = Math.round(mouseX - _dragOffset.x + _posOffset.x);
				_py = Math.round(mouseY - _dragOffset.y + _posOffset.y);
//				SharedObjectManager.getInstance().currentPosition = new Point(-(_px + _cellSize*.5) / _cellSize, -(_py + _cellSize*.5) / _cellSize);
			} else if(!_ttLocked) {
				if(_upPressed) _py += _cellSize * .5;
				if(_downPressed) _py -= _cellSize * .5;
				if(_leftPressed) _px += _cellSize * .5;
				if(_rightPressed) _px -= _cellSize * .5;
			}
			render();
		}


		// __________________________________________________________ MOUSE EVENTS
		/**		 * Called when the map is clicked.		 * It locks the tooltip to be able to use the options on it.		 */
		protected function clickHandler(event:MouseEvent):void {
			if(_tooltip.contains(event.target as DisplayObject)) return;
			if(Math.abs(_dragOffset.x - mouseX) > 2 || Math.abs(_dragOffset.y - mouseY) > 2 || !_ttContent.isInteractive) return;
			_ttLocked = !_ttLocked;
			_tooltip.mouseChildren = _ttLocked;
			_tooltip.mouseEnabled = _ttLocked;
			if(_ttLocked){
				_pressed = false;
				_ttContent.displayFull();
				_spin.visible = false;
				TweenLite.to(_disableLayer, .5, {autoAlpha:1});
//				var px:Number = _px + (_width * .5 - mouseX);
//				var py:Number = _py + (_height * .5 - mouseY);
//				TweenLite.to(this, .5, {ease:Sine.easeInOut, posX:px, posY:py, onUpdate:render, onUpdateParams:[true], onComplete:checkForLoading});
			}
		}


		/**		 * Called when mouse is pressed.		 */
		protected function mouseDownHandler(event:MouseEvent):void {
			if(_tooltip.contains(event.target as DisplayObject) || !_enabled) return;
			_ttLocked = false;
			_spin.visible = true;
			_disableLayer.alpha = 0;
			_disableLayer.visible = false;
			_dragOffset = new Point(mouseX, mouseY);
			_posOffset = new Point(_px, _py);
			_pressed = true;
		}


		/**		 * Called when mouse is released.		 */
		protected function mouseUpHandler(event:MouseEvent):void {
			if(!_pressed) return;
			_pressed = false;
			checkForLoading();
		}
	}
}