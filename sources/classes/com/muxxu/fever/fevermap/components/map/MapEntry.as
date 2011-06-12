package com.muxxu.fever.fevermap.components.map {

	import com.nurun.utils.frame.FrameTimer;
	import com.nurun.utils.frame.events.FrameTimerEvent;
	
	/**
		private var _rawData:XML;
		private var _timer:FrameTimer;
		private var _isBuilt:Boolean;
		private var _lastZoom:int;
			_icon.canRender = false;
			_isBuilt = false;
			_lastZoom = -1;
		public function delayBuild(frames:int, zoom:int, lastUpdateTime:Number, force:Boolean):void {
			
			_isBuilt = false;
			_lastZoom = zoom;
			_previousUpdateTime = lastUpdateTime;
			
			if(frames == 0) {
				_isBuilt = true;
				_icon.canRender = false;
				if(_timer != null) {
					_timer.removeEventListener(FrameTimerEvent.COMPLETE, delayBuildComplete);
					_timer.dispose();
				}
				_timer = new FrameTimer(frames);
			_icon.setImageByZoomLevel(zoom);
		}

		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			if(_timer != null) {
				_timer.removeEventListener(FrameTimerEvent.COMPLETE, delayBuildComplete);
				_timer.dispose();
				_timer = null;
			}
		}
			_icon.canRender = true;
			_icon.setImageByZoomLevel(-1);
			_isBuilt = true;