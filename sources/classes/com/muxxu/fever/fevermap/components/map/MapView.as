package com.muxxu.fever.fevermap.components.map {

	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.graphics.PinEndGraphic;
	import com.muxxu.fever.graphics.PinStartGraphic;

	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Francois
	 * @date 13 mars 2011;
	 */
	public class MapView extends MapEngine {
		
		private var _startPin:PinStartGraphic;
		private var _endPin:PinEndGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapView</code>.
		 */
		public function MapView() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		override public function populate(data:Vector.<MapEntry>, dataRect:Rectangle):void {
			super.populate(data, dataRect);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * @inheritDoc
		 */
		override protected function initialize():void {
			super.initialize();
			_startPin = new PinStartGraphic();
			_endPin = new PinEndGraphic();
			_startPin.filters = _endPin.filters = [new DropShadowFilter(4,0,0,.5,10,10,1,2)];
			DataManager.getInstance().addEventListener(DataManagerEvent.PATH_FINDER_PATH_FOUND, pathHandler);
		}
		
		/**
		 * Called when a new path is available.
		 */
		private function pathHandler(event:DataManagerEvent):void {
			if(_overlay.contains(_startPin)){
				_overlay.removeChild(_startPin);
				_overlay.removeChild(_endPin);
			}
			renderLayer();
			render(true);
			if(DataManager.getInstance().currentPath != null) {
				centerOn(DataManager.getInstance().currentPath[0]);
			}
		}

		/**
		 * Called when underlay and overlay need to be rendered
		 */
		override protected function renderLayer():void {
			var currentPath:Array = DataManager.getInstance().currentPath;
			_underlay.graphics.clear();
			if(currentPath != null) {
				var i:int, len:int;
				len = currentPath.length;
				for(i = 0; i < len; ++i) {
					_underlay.graphics.beginFill(0xff0000, .5);
					_underlay.graphics.drawRect(currentPath[i].x * _cellSize, currentPath[i].y * _cellSize, _cellSize, _cellSize);
					_underlay.graphics.endFill();
				}
				if(_zoomLevel < 5) {
					_overlay.addChild(_startPin);
					_overlay.addChild(_endPin);
					_startPin.scaleX = _startPin.scaleY = 
					_endPin.scaleX = _endPin.scaleY = _cellSize/16;
					_startPin.x = currentPath[0].x * _cellSize + _cellSize * .5 - _startPin.width;
					_startPin.y = currentPath[0].y * _cellSize + _cellSize * .5 - _startPin.height;
					_endPin.x = currentPath[len-1].x * _cellSize + _cellSize * .5 - _endPin.width;
					_endPin.y = currentPath[len-1].y * _cellSize + _cellSize * .5 - _endPin.height;
				}else if(_overlay.contains(_startPin)){
					_overlay.removeChild(_startPin);
					_overlay.removeChild(_endPin);
				}
			}
		}
		
	}
}