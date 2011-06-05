package com.muxxu.fever.fevermap.components.map {

	import com.nurun.utils.frame.FrameTimer;
	import com.nurun.utils.frame.events.FrameTimerEvent;
	
	/**	 * Contains the data about a map's point.	 * 	 * @author  Francois	 */	public class MapEntry {		private var _x:Number;		private var _y:int;		private var _icon:IZoomableMapItem;
		private var _rawData:XML;
		private var _timer:FrameTimer;
		private var _isBuilt:Boolean;
		private var _lastZoom:int;		private var _previousUpdateTime:Number;								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>MapEntry</code>.		 */		public function MapEntry(x:Number, y:int, icon:IZoomableMapItem, rawData:XML) {			_rawData = rawData;			_x = x;			_y = y;			_icon = icon;
			_icon.canRender = false;
			_isBuilt = false;
			_lastZoom = -1;		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the X coordinate.		 */		public function get x():Number { return _x; }				/**		 * Gets the Y coordinate.		 */		public function get y():int { return _y; }				/**		 * Gets the icon to display on the map.		 */		public function get icon():IZoomableMapItem { return _icon; }				/**		 * Sets the icon to display on the map.		 */		public function set icon(value:IZoomableMapItem):void { _icon = value; }				/**		 * Gets the raw XML data.		 */		public function get rawData():XML { return _rawData; }				/**		 * Sets the raw XML data.		 */		public function set rawData(value:XML):void { _rawData = value; }				/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Gets a String representation of the object.		 */		public function toString():String {			return "[MapEntry :: x="+x+", y="+y+"]";		}				/**		 * Sets the delayed build time in frames		 */
		public function delayBuild(frames:int, zoom:int, lastUpdateTime:Number, force:Boolean):void {			if(_isBuilt && _lastZoom == zoom && _previousUpdateTime == lastUpdateTime && !force) return;
			
			_isBuilt = false;
			_lastZoom = zoom;
			_previousUpdateTime = lastUpdateTime;
			
			if(frames == 0) {				_icon.canRender = true;
				_isBuilt = true;			}else{
				_icon.canRender = false;
				if(_timer != null) {
					_timer.removeEventListener(FrameTimerEvent.COMPLETE, delayBuildComplete);
					_timer.dispose();
				}
				_timer = new FrameTimer(frames);				_timer.addEventListener(FrameTimerEvent.COMPLETE, delayBuildComplete);				_timer.start();			}
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
		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Called when timer completes		 */		private function delayBuildComplete(event:FrameTimerEvent):void {
			_icon.canRender = true;
			_icon.setImageByZoomLevel(-1);
			_isBuilt = true;		}	}}