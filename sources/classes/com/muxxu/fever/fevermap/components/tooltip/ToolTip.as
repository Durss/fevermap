package com.muxxu.fever.fevermap.components.tooltip {

	import com.nurun.core.lang.Disposable;
	import com.muxxu.fever.fevermap.components.tooltip.content.ToolTipContent;
	import com.muxxu.fever.fevermap.vo.ToolTipMessage;
	import com.muxxu.fever.graphics.BackToolTipGraphic;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
		/**	 * Displays a tooltip.	 * 	 * @author  Francois	 */	public class ToolTip extends Sprite implements Disposable {		private var _currentContent:ToolTipContent;		private var _target:InteractiveObject;		private var _background:BackToolTipGraphic;		private var _opened:Boolean;
								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ToolTip</code>.		 */		public function ToolTip() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the virtual component's height.		 */		override public function get height():Number { return _background.height; }				/**		 * Gets the virtual component's width.		 */		override public function get width():Number { return _background.width; }				/**		 * Sets the X and restrict it to be always visible.		 */
		override public function set x(value:Number):void {
			if(_currentContent != null && _currentContent.locked) return;
			super.x = value;			var globPoint:Point = localToGlobal(new Point(0, 0));
			if(stage != null) {				if(globPoint.x < 0) value -= globPoint.x;				if(globPoint.x > stage.stageWidth - width) value -= globPoint.x - (stage.stageWidth - width);			}			super.x = value;		}				/**		 * Sets the X and restrict it to be always visible.		 */		override public function set y(value:Number):void {
			if(_currentContent != null && _currentContent.locked) return;			super.y = value;			var globPoint:Point = localToGlobal(new Point(0, 0));			if(globPoint.y < 0) value -= globPoint.y;//globalToLocal(new Point(0,0)).y;			if(stage != null) {				if(globPoint.y > stage.stageHeight - height) value -= globPoint.y - (stage.stageHeight - height);			}			super.y = value;		}						/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Opens the tooltip with a specific content.		 */		public function open(data:ToolTipMessage):void {			//If we display the same content			if(_currentContent != data.content) {				if(_currentContent != null) {					removeChild(_currentContent as DisplayObject);					_currentContent.dispose();					_currentContent.removeEventListener(Event.CLOSE, close);					_currentContent.removeEventListener(Event.RESIZE, computePositions);				}				_currentContent = data.content;				_currentContent.addEventListener(Event.CLOSE, close);				_currentContent.addEventListener(Event.RESIZE, computePositions);				addChild(_currentContent as DisplayObject);				computePositions();			}
			if(!_opened) {
				alpha = 1;
				visible = true;			}			_opened = true;		}		/**		 * Closes the tooltip.		 */		public function close(...arg):void {			if(_opened && (_currentContent != null && !_currentContent.locked)) {				_target = null;				_opened = false;
				visible = false;
				alpha = 0;
				dispatchEvent(new Event(Event.CLOSE));			}		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			if(_currentContent != null) {
				_currentContent.dispose();
				_currentContent.removeEventListener(Event.CLOSE, close);
				_currentContent.removeEventListener(Event.RESIZE, computePositions);
			}
			
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			filters = [];
		}								/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_background = addChild(new BackToolTipGraphic()) as BackToolTipGraphic;						alpha = 0;			visible = false;
			filters = [new DropShadowFilter(4,45,0,.6,8,8,.8,3)];		}		/**		 * Resize and replace the elements.		 */		private function computePositions(e:Event = null):void {			var content:DisplayObject = _currentContent as DisplayObject;			var margin:int		= 3;			var windowMargin:int= 10;			var backW:int		= Math.round(content.width + margin * 2) - 1;			var backH:int		= Math.round(content.height + margin * 2) - 1;						if(_target != null) {				var bounds:Rectangle= _target.getBounds(_target);				var pos:Point		= _target.localToGlobal(new Point(bounds.x, bounds.y));				pos.x				= Math.round(pos.x + (bounds.width - backW) * .5 );				pos.y				= Math.round(pos.y - backH - 10 );								if(stage != null) {					if(pos.x < windowMargin)								pos.x = windowMargin;					if(pos.x > stage.stageWidth - backW - windowMargin)		pos.x = stage.stageWidth - backW - windowMargin;					if(pos.y < 0)											pos.y = windowMargin;					if(pos.y > stage.stageHeight - backH - windowMargin)	pos.y = stage.stageHeight - backH - windowMargin;				}								x = pos.x;				y = pos.y;
			}
			_background.width = _background.width = backW;			_background.height = _background.height = backH;			content.x = content.y = margin;		}	}}