package com.muxxu.fever.fevermap.components.menu.world {
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;

	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 16 févr. 2011;
	 */
	public class WorldSelector extends AbstractMenuContent implements IMenuContent {

		private var _buttons:Vector.<BaseButton>;
		private var _buttonToId:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>WorldSelector</code>.
		 */
		public function WorldSelector() {
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
			nodes = new XML(Config.getVariable("worlds")).child("world");
			len = nodes.length();
			_buttons = new Vector.<BaseButton>(len, true);
			_buttonToId = new Dictionary();
			py = 2;
			for(i = 0; i < len; ++i) {
				clazz = getDefinitionByName(String(nodes[i].@icon)) as Class;
				_buttons[i] = _container.addChild(new BaseButton(Label.getLabel(nodes[i][0]), "button", null, new clazz())) as BaseButton;
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
			DataManager.getInstance().setWorld(_buttonToId[event.target]);
			close();
		}
		
	}
}