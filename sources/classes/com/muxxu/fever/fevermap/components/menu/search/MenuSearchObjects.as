package com.muxxu.fever.fevermap.components.menu.search {

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.ObjectChecker;
	import com.muxxu.fever.fevermap.components.tooltip.ToolTip;
	import com.muxxu.fever.fevermap.components.tooltip.content.TTTextContent;
	import com.muxxu.fever.fevermap.data.Constants;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.vo.ToolTipMessage;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 13 mars 2011;
	 */
	public class MenuSearchObjects extends Sprite implements Disposable {

		private var _buttonsCtn:Sprite;
		private var _resetBt:FeverButton;
		private var _tooltip:ToolTip;
		private var _ttMessage:ToolTipMessage;
		private var _items:Vector.<ObjectChecker>;
		private var _title:CssTextField;
		private var _width:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuSearchObjects</code>.
		 */
		public function MenuSearchObjects(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _resetBt.y + _resetBt.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				_items[i].tabIndex = value++;
			}
			_resetBt.tabIndex = value++;
			return value;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(_buttonsCtn.numChildren > 0) {
				if(_buttonsCtn.getChildAt(0) is Disposable) Disposable(_buttonsCtn.getChildAt(0)).dispose();
				_buttonsCtn.removeChildAt(0);
			}
			
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				_items[i].removeEventListener(Event.CHANGE, changeSelectionHandler);
			}
			
			_items = null;
			
			_resetBt.removeEventListener(MouseEvent.CLICK, clickResetHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_buttonsCtn	= addChild(new Sprite()) as Sprite;
			_title		= addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_resetBt	= addChild(new FeverButton(Label.getLabel("selectorReset"))) as FeverButton;
			_tooltip	= addChild(new ToolTip()) as ToolTip;
			_ttMessage	= new ToolTipMessage(new TTTextContent());
			
			_tooltip.mouseChildren = false;
			_tooltip.mouseEnabled = false;
			_title.text = Label.getLabel("menuSearchObjectsTitle");
			_title.background = true;
			_title.backgroundColor = 0;
			_title.width = _width;
			
			var i:int, len:int, item:ObjectChecker, iconClass:Class;
			_items = new Vector.<ObjectChecker>();
			len = Constants.ITEMS + 1;
			for(i = 1; i < len; ++i) {
				item	= _buttonsCtn.addChild(new ObjectChecker(i)) as ObjectChecker;
				item.validate();
				item.addEventListener(Event.CHANGE, changeSelectionHandler);
				_items.push(item);
			}
			
			_resetBt.addEventListener(MouseEvent.CLICK, clickResetHandler);
			addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			PosUtils.hDistribute(_items, _width, 2, 2);
			
			_resetBt.validate();
			
			PosUtils.vPlaceNext(5, _title, _buttonsCtn, _resetBt);
			
			PosUtils.hCenterIn(_resetBt, _buttonsCtn);
			_resetBt.x = Math.max(0, _resetBt.x);
			
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS

		/**
		 * Called when a button's state changes
		 */
		private function changeSelectionHandler(event:Event):void {
			var i:int, len:int, ids:Array;
			len = _items.length;
			ids = [];
			for(i = 0; i < len; ++i) {
				if(_items[i].selected) {
					ids.push(_items[i].objectId);
				}
			}
			DataManager.getInstance().setFilters(ids);
		}
		
		/**
		 * Called when reset button is clicked
		 */
		private function clickResetHandler(event:MouseEvent):void {
			var i:int, len:int;
			len = _items.length;
			for(i = 0; i < len; ++i) {
				_items[i].unSelect();
			}
			DataManager.getInstance().setFilters([]);
		}
		
		/**
		 * Called when an item is rolled over.
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(event.target is ObjectChecker) {
				_buttonsCtn.addChild(_tooltip);
				var bt:ObjectChecker = event.target as ObjectChecker;
				TTTextContent(_ttMessage.content).populate(Label.getLabel("itemName"+bt.objectId));
				_tooltip.open(_ttMessage);
				_tooltip.x = bt.x + bt.width;
				_tooltip.y = bt.y + Math.round((bt.height - _tooltip.height) * .5);
			}
		}
		
		/**
		 * Called when an item is rolled out.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			_tooltip.close();
			if(_buttonsCtn.contains(_tooltip)) _buttonsCtn.removeChild(_tooltip);
		}
		
	}
}