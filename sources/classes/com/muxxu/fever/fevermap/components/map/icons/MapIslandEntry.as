package com.muxxu.fever.fevermap.components.map.icons {
	import by.blooddy.crypto.serialization.JSON;

	import com.muxxu.fever.fevermap.components.map.IZoomableMapItem;
	import com.muxxu.fever.fevermap.components.map.MapEntryEvent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.utils.IslandDrawer;
	import com.muxxu.fever.graphics.EmptyIslandGraphic;
	import com.muxxu.fever.graphics.IslandZoom1Graphic;
	import com.muxxu.fever.graphics.IslandZoom2Graphic;
	import com.muxxu.fever.graphics.IslandZoom3Graphic;
	import com.muxxu.fever.graphics.IslandZoom4Graphic;
	import com.muxxu.fever.graphics.PathIslandGraphic;
	import com.muxxu.fever.graphics.PoustyGraphic;
	import com.muxxu.fever.graphics.RainbowIslandBigGraphic;
	import com.muxxu.fever.graphics.RainbowIslandGraphic;
	import com.nurun.core.lang.boolean.parseBoolean;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Displays an island icon.
	 * 
	 * @author Francois
	 * @date 5 nov. 2010;
	 */
	public class MapIslandEntry extends Bitmap implements IZoomableMapItem {

		private var _position:Point;
		private var _data:XML;
		private var _zoom:int;
		private var _island:DisplayObject;
		private var _canRender:Boolean;
		private var _lastZoom:int;
		private var _isTempRendering:Boolean;
		private var _renderMode:int;
		
		
		


		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapIslandEntry</code>.
		 */
		public function MapIslandEntry(position:Point, data:XML) {
			_data = data;
			_position = position;
		}


		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function set canRender(value:Boolean):void { _canRender = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get zoomLevel():int { return _zoom; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Updates the component
		 */
		public function update():void {
			setImageByZoomLevel(_zoom);
		}
		//
		//found at http://www.actionscript.org/forums/showpost.php3?p=794474&postcount=4
		//
		public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number):uint {
			var q:Number = 1-progress;
			var fromA:uint = (fromColor >> 24) & 0xFF;
			var fromR:uint = (fromColor >> 16) & 0xFF;
			var fromG:uint = (fromColor >>  8) & 0xFF;
			var fromB:uint =  fromColor        & 0xFF;
			var toA:uint = (toColor >> 24) & 0xFF;
			var toR:uint = (toColor >> 16) & 0xFF;
			var toG:uint = (toColor >>  8) & 0xFF;
			var toB:uint =  toColor        & 0xFF;
			var resultA:uint = fromA*q + toA*progress;
			var resultR:uint = fromR*q + toR*progress;
			var resultG:uint = fromG*q + toG*progress;
			var resultB:uint = fromB*q + toB*progress;
			var resultColor:uint = resultA << 24 | resultR << 16 | resultG << 8 | resultB;
			return resultColor;
			}
			
		/**
		 * @inheritDoc
		 */
		public function setImageByZoomLevel(zoom:int):void {
			var m:Matrix;
			var matrix:Array;
			var filters:String, indexes:Array, i:int, len:int, percent:Number, color:int, alpha:int, sum:int;
			if(zoom != -1) _zoom = zoom;
			
			if(bitmapData != null && zoom != _lastZoom) bitmapData.dispose();
			
			_renderMode = SharedObjectManager.getInstance().renderMode;
			if(_renderMode == 0 || _zoom == 5) {
				switch(_zoom){
					case 1:
						_island = new IslandZoom1Graphic();
						break;
					case 2:
						_island = new IslandZoom2Graphic();
						setRandomFrame(_island as MovieClip);
						break;
					case 3:
						_island = new IslandZoom3Graphic();
						setRandomFrame(_island as MovieClip);
						break;
					case 5:
						bitmapData = new BitmapData(350, 350, true, 0);
						updateLinks();
						_island = renderIsland();
						break;
					case 4:
					default:
						_island = new IslandZoom4Graphic();
						setRandomFrame(_island as MovieClip);
						break;
				}
			}else if(_renderMode == 1) {
				_island = new PathIslandGraphic();
				MovieClip(_island).gotoAndStop(parseInt(_data.@d, 2));
				_island.scaleX = _island.scaleY = _zoom == 5? 350/_island.width : _zoom / 4;
			}else if(_renderMode == 2) {
				percent = parseInt(_data.@p)/parseInt(_data.@t);
				color = interpolateColor(0x509101, 0, (percent > 0)? Math.min(1, percent * 50 + .15) : 0);
				alpha = 0xff * .5;
				bitmapData = new BitmapData(_zoom * 16, _zoom * 16, true, color | (alpha << 24));
				displayPousty();
				bitmapData.lock();
				return;
			}else if(_renderMode == 3) {
				if(String(_data.@e).length > 0 && String(_data.@data).length > 0) {
					var ennemies:Array = String(_data.@e).split(",");
					var points:Array = [];
					points[1] = 1;
					points[9] = 2;
					points[5] = 3;
					points[2] = 4;
					points[4] = 5;
					points[8] = 6;
					points[12] = 7;
					points[6] = 8;
					points[3] = 9;
					points[14] = 10;
					points[16] = 11;
					points[7] = 12;
					points[10] = 20;
					points[15] = 25;
					points[11] = 30;
					len = ennemies.length;
					for(i = 0; i < len; ++i) {
						sum += points[parseInt(ennemies[i])];
					}
					percent = sum/300;
					color = interpolateColor(0x509101, 0x910000, (percent > 0)? Math.min(1, percent) : 0);
				}else{
					color = 0;
				}
				alpha = 0xff * .5;
				bitmapData = new BitmapData(_zoom * 16, _zoom * 16, true, color | (alpha << 24));
				displayPousty();
				bitmapData.lock();
				return;
			}else if(_renderMode == 4) {
				alpha = 0xff * .5;
				color = parseBoolean(_data.@c)? 0x509101 : 0x910000;
				bitmapData = new BitmapData(_zoom * 16, _zoom * 16, true, color | (alpha << 24));
				displayPousty();
				bitmapData.lock();
				return;
			}else if(_renderMode == 5) {
				var isGround:Boolean = false;
				if(String(_data.@data).length > 0) {
					matrix = by.blooddy.crypto.serialization.JSON.decode(_data.@data);
					var lenI:int, lenJ:int, j:int, grounds:int;
					var level1Values:Array = [1,2,3,"Wall","Ladder"];
					lenI = matrix.length;
					for(i = 0; i < lenI; ++i) {
						lenJ = matrix[i].length;
						for(j = 0; j < lenJ; ++j) {
							if(level1Values.indexOf( matrix[i][j] ) > -1) grounds ++;
						}
					}
					isGround = grounds > 10;
				}
				alpha = 0xff * .5;
				color = isGround? 0x509101 : 0x910000;
				bitmapData = new BitmapData(_zoom * 16, _zoom * 16, true, color | (alpha << 24));
				displayPousty();
				bitmapData.lock();
				return;
			}
			
			
			if(!_canRender) {
				if(bitmapData == null) {
					bitmapData = new BitmapData(_island.width, _island.height, true, 0);
					if(_zoom < 5) {
						matrix = [	.55, .55, .55, 0, 0,
									.55, .55, .55, 0, 0,
									.55, .55, .55, 0, 0,
									0, 0, 0, .2, 0 ];
						_island.filters = [new ColorMatrixFilter(matrix)];
					}
					m = new Matrix();
					m.scale(_island.scaleX, _island.scaleY);
					bitmapData.draw(_island, m);
					bitmapData.lock();
				}
				_isTempRendering = true;
				return;
			}
			
			_lastZoom = _zoom;
			
			//If not in maximum zoom mode
			if(_zoom < 5) {
				updateVisitedState();
				bitmapData = new BitmapData(_island.width, _island.height, true, 0);
				m = new Matrix();
				m.scale(_island.scaleX, _island.scaleY);
				bitmapData.draw(_island, m);
				
				if(_renderMode == 0) updateLinks();
				if(SharedObjectManager.getInstance().spoil) setItems();
			
				//Filters management
				var a:Number = 1;
				filters = DataManager.getInstance().objectFiltersStr;
				if(filters.length > 0) {
					filters = "," + filters + ",";
					indexes = _data.@i.split(",");
					len = indexes.length;
					a = .3;
					for(i = 0; i < len; ++i) {
						if(filters.indexOf(","+(parseInt(indexes[i])+1)+",") > -1) {
							a = 1;
							break;
						}
					}
				}
				super.alpha = a;
			}
			
			//Pousty's display
			displayPousty(_zoom == 5);
			
//			var tf:CssTextField = new CssTextField("debug");
//			tf.text = _position.toString();
//			bitmapData.draw(tf);
			
			bitmapData.lock();
			dispatchEvent(new MapEntryEvent(MapEntryEvent.UPDATE));
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Displays pousty.
		 */
		private function displayPousty(topLeft:Boolean = false):void {
			var pos:Point = SharedObjectManager.getInstance().playerPosition;
			if(pos.x == _position.x && pos.y == _position.y) {
				var pousty:PoustyGraphic = new PoustyGraphic();
				var m:Matrix = new Matrix();
				if(!topLeft) {
					m.translate(Math.round((bitmapData.width-pousty.width)*.5), Math.round((bitmapData.height-pousty.height)*.5));
				}
				pousty.filters = [new GlowFilter(0xffffff,1,5,5,5,3)];
				bitmapData.draw(pousty, m);
			}
		}
		
		/**
		 * Sets a specific target to a seeded random frame
		 */
		private function setRandomFrame(target:MovieClip):void {
			var frame:int = Math.abs(_position.x + _position.y) % target.totalFrames + 1;
			target.gotoAndStop(frame);
		}
		
		/**
		 * Sets the items images.
		 */
		private function setItems():void {
			if(String(_data.@i).length == 0) return;

			var i:int, len:int, id:int, py:int, indexes:Array, item:DisplayObject, clazz:Class;
			var items:Array, m:Matrix, gottenObjects:Array, exists:Array, showAll:Boolean;
			indexes = _data.@i.split(",");
			items = [];
			exists = [];
			py = 4;
			showAll = SharedObjectManager.getInstance().sgObjects;
			
			if(!showAll) {
				gottenObjects = SharedObjectManager.getInstance().getGotObjectsByArea(_position);
				len = gottenObjects.length;
				for(i = 0; i < len; ++i) exists[parseInt(gottenObjects[i])] = true;
			}
			
			len = Math.min(_zoom * _zoom, indexes.length);
			for(i = 0; i < len; ++i) {
				id = parseInt(indexes[i])+1;
				if(exists[id] === true) continue;
				if(i%(_zoom-1) == 0 && i > 0) py += 15;
				clazz = getDefinitionByName("com.muxxu.fever.graphics.Item" + id + "Graphic") as Class;
				item = new clazz();
				m = new Matrix();
				m.translate((i % (_zoom-1)) * 16 + 10, py);
				item.filters = [new DropShadowFilter(0,0,0,1,3,3,3,3)];
				bitmapData.draw(item, m);
				items.push(item);
			}
		}

		/**
		 * Updates the visited state
		 */
		private function updateVisitedState():void {
			var matrix:Array, so:SharedObjectManager;
			so = SharedObjectManager.getInstance();
			if(so.isAreaCleaned(_position)) {
				_island.filters = [];
			}else if(so.isAreaVisited(_position)) {
				matrix = [0.7740820050239563,0.7883546352386475,-0.5524367094039917,0,-33.96500015258789,0.03289623185992241,0.7596070766448975,0.21749663352966309,0,-33.96500015258789,0.6241744756698608,-0.12081518024206161,0.506640613079071,0,-33.96500015258789,0,0,0,1,0];
				_island.filters = [new ColorMatrixFilter(matrix)];
			} else {
				var v:Number = (_renderMode == 1)? .4 : .55; 
				matrix = [	v, v, v, 0, 0,
							v, v, v, 0, 0,
							v, v, v, 0, 0,
							0, 0, 0, 1, 0 ];
				_island.filters = [new ColorMatrixFilter(matrix)];
			}
			if(String(_data.@i).length > 0 && so.spoilGlow) {
				var f:Array = _island.filters;
				var color:Number = 0xffffff;
				if(so.diffObjects){
					var i:int, len:int, id:int, items:Array, isSingle:Boolean, isMultiple:Boolean;
					items = String(_data.@i).split(",");
					len = items.length;
					for(i = 0; i < len; ++i) {
						id = parseInt(items[i]);
						if(id == 40 || id == 41 || id == 42) continue;
						if(id < 10) isMultiple = true;
						if(id > 9) isSingle = true;
					}
					if(isSingle && isMultiple) color = 0xFF99FF;
					else if(isSingle) color = 0xff0000;
					else if(isMultiple) color = 0x0000ff;
				}
				f.push(new GlowFilter(color, 1, _zoom + .1, _zoom + .1, 15, 3));
				_island.filters = f;
			}
		}

		/**
		 * Updates the links.
		 */
		private function updateLinks():void {
			var bridge:MovieClip = _zoom == 5? new RainbowIslandBigGraphic() : new RainbowIslandGraphic();
			var scale:Number = _zoom == 5? 1 : _zoom / 4;
			bridge.gotoAndStop(parseInt(_data.@d, 2));
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			bitmapData.draw(bridge, m);
		}
		
		/**
		 * Renders the island
		 */
		private function renderIsland():DisplayObject {
			var i:int, j:int, lenI:int, lenJ:int;
			var island:Shape = new Shape();
			if(String(_data.@data).length > 0) {
				var matrix:Array = by.blooddy.crypto.serialization.JSON.decode(_data.@data);
				lenI = matrix.length;
				for(i = 0; i < lenI; ++i) {
					lenJ = matrix[i].length;
					for(j = 0; j < lenJ; ++j) {
						IslandDrawer.drawItemToGrid(bitmapData, matrix[i][j], j, i, 16, 0, false, new Point(16,16));
					}
				}
				bitmapData.lock();
			}else{
				var src:MovieClip = new EmptyIslandGraphic();
				setRandomFrame(src);
				var m:Matrix = new Matrix();
				m.translate(Math.round((20*16 - src.width)*.5), Math.round((20*16 - src.height)*.5));
				bitmapData.draw(src, m);
			}
			return island;
		}
		
	}
}