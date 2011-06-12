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
	

		override public function set x(value:Number):void {
			if(_currentContent != null && _currentContent.locked) return;
			super.x = value;
			if(stage != null) {
			if(_currentContent != null && _currentContent.locked) return;
			if(!_opened) {
				alpha = 1;
				visible = true;
				visible = false;
				alpha = 0;
				dispatchEvent(new Event(Event.CLOSE));
		
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
		}
			filters = [new DropShadowFilter(4,45,0,.6,8,8,.8,3)];
			}
			_background.width = _background.width = backW;