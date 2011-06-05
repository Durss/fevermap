package com.muxxu.fever.fevermap.components.map.icons {	import com.muxxu.fever.fevermap.components.map.IZoomableMapItem;	import com.muxxu.fever.fevermap.data.SharedObjectManager;	import com.muxxu.fever.graphics.WaterZoom1Graphic;	import com.muxxu.fever.graphics.WaterZoom2Graphic;	import com.muxxu.fever.graphics.WaterZoom3Graphic;	import com.muxxu.fever.graphics.WaterZoom4Graphic;	import com.muxxu.fever.graphics.WaterZoom5Graphic;	import flash.display.Sprite;	import flash.filters.ColorMatrixFilter;
		/**
	 * Creates the map pattern	 * 	 * @author Francois	 */
	public class MapIconMapPattern extends Sprite implements IZoomableMapItem {
				private var _zoom:int;						

		/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>MapIconMapPattern</code>.		 */		public function MapIconMapPattern() { }						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set canRender(value:Boolean):void { }
		
		/**
		 * @inheritDoc
		 */
		public function get zoomLevel():int { return _zoom; }		/* ****** *		 * PUBLIC *		 * ****** */
		/**
		 * @inheritDoc
		 */		public function setImageByZoomLevel(zoom:int):void {
			_zoom = zoom;
			while(numChildren > 0) removeChildAt(0);
						switch(zoom){				case 1:					addChild(new WaterZoom1Graphic());					break;				case 2:					addChild(new WaterZoom2Graphic());					break;				case 3:					addChild(new WaterZoom3Graphic());					break;				case 5:					addChild(new WaterZoom5Graphic());
					break;				case 4:
				default:
					addChild(new WaterZoom4Graphic());
					break;			}
			if(SharedObjectManager.getInstance().localMode) {
				filters = [new ColorMatrixFilter([.33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0])];			}
		}
						/* ******* *		 * PRIVATE *		 * ******* */			}}