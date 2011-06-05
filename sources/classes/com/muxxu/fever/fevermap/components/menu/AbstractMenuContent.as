package com.muxxu.fever.fevermap.components.menu {

	import com.nurun.core.lang.Disposable;
	import com.muxxu.fever.fevermap.components.map.MapEngine;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Francois
	 * @date 16 janv. 2011;
	 */
	public class AbstractMenuContent extends Sprite implements Disposable {

		protected var _margin:int = 5;
		protected var _container:Sprite;
		protected var _map:MapEngine;
		protected var _back:Sprite;
		protected var _locked:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>AbstractMenuContent</code>.
		 */
		public function AbstractMenuContent() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the map's reference.
		 */
		public function set map(value:MapEngine):void { _map = value; }
		
		/**
		 * Gets the background's reference
		 */
		public function get background():Sprite { return _back; }
		
		/**
		 * Gets if the menu is locked or not (to prevent from auto closing)
		 */
		public function get locked():Boolean { return _locked; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function open():void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(_container.numChildren > 0) {
				if(_container.getChildAt(0) is Disposable) Disposable(_container.getChildAt(0)).dispose();
				_container.removeChildAt(0);
			}
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_map = null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		protected function initialize():void {
			_back = addChild(new Sprite()) as Sprite;
			_container = addChild(new Sprite()) as Sprite;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		protected function computePositions():void {
			_container.x = _container.y = _margin;
			_back.graphics.clear();
			_back.graphics.lineStyle(0, 0x271714, 1);
			_back.graphics.beginFill(0x412720, 1);
			_back.graphics.drawRect(0, 0, Math.round(_container.width + _margin*2) - 1, Math.round(_container.height + _margin*2) - 1);
			_back.graphics.endFill();
		}
		
	}
}