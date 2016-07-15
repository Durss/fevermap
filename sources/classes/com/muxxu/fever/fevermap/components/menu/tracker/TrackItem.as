package com.muxxu.fever.fevermap.components.menu.tracker {

	import by.blooddy.crypto.serialization.JSON;

	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.graphics.TrackerAddIconGraphic;
	import com.muxxu.fever.graphics.TrackerEditIconGraphic;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 19 janv. 2011;
	 */
	public class TrackItem extends Sprite implements Disposable {

		private const _WIDTH:int = 103;
		private const _CONTENT_HEIGHT:int = 103;
		private const _HEADER_HEIGHT:int = 17;
		private const _CELL_SIZE:int = 5;
		
		private var _title:CssTextField;
		private var _drawHolder:Shape;
		private var _data:Revision;
		private var _iconAdd:TrackerAddIconGraphic;
		private var _iconEdit:TrackerEditIconGraphic;
		private var _infos:CssTextField;
		private var _mask:Shape;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TrackItem</code>.
		 */
		public function TrackItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the island's position
		 */
		public function get pos():Point { return new Point(_data.x, _data.y); }
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _WIDTH; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _infos.y + _infos.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the item.
		 */
		public function populate(data:Revision):void {
			_data = data;
			populateMatrix(by.blooddy.crypto.serialization.JSON.decode(_data.matrix));
		}
		
		/**
		 * Clears everything
		 */
		public function clear():void {
			_drawHolder.graphics.clear();
			_title.text = "";
			_infos.text = "";
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			_drawHolder.filters = [];
			_drawHolder.graphics.clear();
			
			_data = null;
						
			removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_iconEdit	= new TrackerEditIconGraphic();
			_iconAdd	= new TrackerAddIconGraphic();
			_drawHolder	= addChild(new Shape()) as Shape;
			_title		= addChild(new CssTextField("menuContentTrackTitle")) as CssTextField;
			_infos		= addChild(new CssTextField("menuContentTrackInfos")) as CssTextField;
			_mask		= addChild(new Shape()) as Shape;
			
			_drawHolder.mask = _mask;
			_iconEdit.x = 5;
			_iconAdd.x = 3;
			_iconEdit.y = _iconAdd.y = 3;
			_title.x = Math.max(_iconEdit.width, _iconAdd.width) + _iconAdd.x;
			_title.y = -1;
			_title.width = _WIDTH - _title.x;
			_infos.wordWrap = false;
			_infos.width = _WIDTH - 1;
			_infos.border = true;
			_infos.borderColor = 0;
			_infos.background = true;
			_infos.backgroundColor = 0x724338;
			_infos.y = _CONTENT_HEIGHT + _HEADER_HEIGHT - 1;
			_drawHolder.filters = [new DropShadowFilter(0,0,0,.75,5,5,1,2)];
			
			_mask.graphics.beginFill(0xff0000, 0);
			_mask.graphics.drawRect(1, _HEADER_HEIGHT + 1, _WIDTH - 2, _CONTENT_HEIGHT - 2);
			_mask.graphics.endFill();
			
			graphics.beginFill(0, 1);
			graphics.drawRect(0, 0, _WIDTH, _HEADER_HEIGHT);
			graphics.endFill();
			graphics.lineStyle(1, 0);
			graphics.beginFill(0x79A8EC, 1);
			graphics.drawRect(0, _HEADER_HEIGHT, _WIDTH - 1, _CONTENT_HEIGHT - 1);
			graphics.endFill();
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * Called when the component is rolled out.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			populateMatrix(by.blooddy.crypto.serialization.JSON.decode(_data.matrix));
		}
		
		/**
		 * Called when the component is rolled over
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(_data.matrixBefore.length > 0) {
				populateMatrix(by.blooddy.crypto.serialization.JSON.decode(_data.matrixBefore));
				_infos.text = Label.getLabel("menuTrackItemInfosBefore");
			}
		}
		
		/**
		 * Populates the component with a matrix revision
		 */
		private function populateMatrix(matrix:Array, alpha:Number = 1, clear:Boolean = true):void {
			var i:int, j:int, lenI:int, lenJ:int, minx:int, miny:int, m:Matrix, color:int, value:String, clazz:Class;
			lenI = matrix.length;
			if(clear) _drawHolder.graphics.clear();
			minx = miny = int.MAX_VALUE;
			for(i = 0; i < lenI; ++i) {
				lenJ = matrix[i].length;
				for(j = 0; j < lenJ; ++j) {
					if(matrix[i][j] is Array) {
						value = matrix[i][j][1];
					}else{
						value = matrix[i][j];
					}
					
					if(value != "0") {
						m = new Matrix();
						m.translate(j * _CELL_SIZE + 1, i * _CELL_SIZE + 1);
						if(value.substr(0,1).toLowerCase() == "e") {
							color = 0xCC0000;
						}else if(value.substr(0,1).toLowerCase() == "i") {
							color = 0x0000FF;
						}else if(value.toLowerCase() == "rainbow") {
							color = 0xFFFF00;
						}else if(value.toLowerCase() == "wall") {
							color = 0xcb9472;
						}else{
							color = 0x509101;
						}
						_drawHolder.graphics.lineStyle(0,0);
						_drawHolder.graphics.beginFill(color, alpha);
						_drawHolder.graphics.drawRect(j * _CELL_SIZE, i * _CELL_SIZE, _CELL_SIZE, _CELL_SIZE);
						minx = Math.min(j * _CELL_SIZE, minx);
						miny = Math.min(i * _CELL_SIZE, miny);
					}
				}
			}
			
			_title.text = parseLabel(Label.getLabel("menuTrackItemTitle"));
			_infos.text = parseLabel(Label.getLabel("menuTrackItemInfos"));
			
			_drawHolder.y = Math.floor((_CONTENT_HEIGHT - _drawHolder.height) * .5) - miny + _HEADER_HEIGHT;
			_drawHolder.x = Math.floor((_WIDTH - _drawHolder.width) * .5) - minx;
			
			if(_data.isNew) {
				addChild(_iconAdd);
				if(contains(_iconEdit)) removeChild(_iconEdit);
			}else{
				addChild(_iconEdit);
				if(contains(_iconAdd)) removeChild(_iconAdd);
			}
		}

		
		/**
		 * Parses a label.
		 */
		private function parseLabel(label:String):String {
			label = label.replace(/\$\{X\}/gi, _data.x);
			label = label.replace(/\$\{Y\}/gi, _data.y);
			label = label.replace(/\$\{PSEUDO\}/gi, _data.pseudo);
			return label;
		}
		
	}
}