package com.muxxu.fever.fevermap.components.menu.l10n {

	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.IconAlign;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.nurun.components.button.BaseButton;
	import com.nurun.structure.environnement.configuration.Config;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 16 févr. 2011;
	 */
	public class MenuLangSelector extends AbstractMenuContent implements IMenuContent {

		private var _buttons:Vector.<BaseButton>;
		private var _buttonToId:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuLangSelector</code>.
		 */
		public function MenuLangSelector() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		public function setTabIndexes(value:int):int { return value; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			super.dispose();
			_buttons = null;
			_buttonToId = null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			var i:int, len:int, nodes:XMLList, py:int, clazz:Class;
			nodes = new XML(Config.getVariable("langs")).child("lang");
			len = nodes.length();
			_buttons = new Vector.<BaseButton>(len, true);
			_buttonToId = new Dictionary();
			py = 2;
			for(i = 0; i < len; ++i) {
				clazz = getDefinitionByName("com.muxxu.fever.graphics.Flag"+String(nodes[i].@id).toUpperCase()+"Bmp") as Class;
				_buttons[i] = _container.addChild(new BaseButton(nodes[i][0], "button", null, new Bitmap(new clazz(NaN, NaN)))) as BaseButton;
				_buttons[i].y = py;
				_buttons[i].iconAlign = IconAlign.LEFT;
				_buttons[i].accept(new CssVisitor());
				_buttonToId[_buttons[i]] = nodes[i].@id;
				py += _buttons[i].height + 5;
			}
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}

		private function clickHandler(event:MouseEvent):void {
			if(_buttonToId[event.target] == null) return;
			
			var path:String = Config.getUncomputedPath("changeLang").replace(/\$\{CODE\}/gi, _buttonToId[event.target]);
			navigateToURL(new URLRequest(path), "_self");
		}
		
	}
}