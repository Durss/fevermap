package com.muxxu.fever.fevermap.components.map.icons {
	
	 * Creates the map pattern
	public class MapIconMapPattern extends Sprite implements IZoomableMapItem {
		

		/* *********** *
		/**
		 * @inheritDoc
		 */
		public function set canRender(value:Boolean):void { }
		
		/**
		 * @inheritDoc
		 */
		public function get zoomLevel():int { return _zoom; }
		/**
		 * @inheritDoc
		 */
			_zoom = zoom;
			while(numChildren > 0) removeChildAt(0);
			
					break;
				default:
					addChild(new WaterZoom4Graphic());
					break;
			if(SharedObjectManager.getInstance().localMode) {
				filters = [new ColorMatrixFilter([.33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0])];
		}
