package com.muxxu.fever.fevermap.components.menu {

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.map.MapEngine;
	import com.muxxu.fever.fevermap.components.menu.filters.MenuFilters;
	import com.muxxu.fever.fevermap.components.menu.help.MenuHelp;
	import com.muxxu.fever.fevermap.components.menu.l10n.MenuLangSelector;
	import com.muxxu.fever.fevermap.components.menu.message.MenuMessage;
	import com.muxxu.fever.fevermap.components.menu.nav.MenuNavigation;
	import com.muxxu.fever.fevermap.components.menu.search.MenuSearch;
	import com.muxxu.fever.fevermap.components.menu.tracker.MenuTracker;
	import com.muxxu.fever.fevermap.components.menu.zoom.MenuZoom;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.events.NurunButtonEvent;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.vo.Margin;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.array.ArrayUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	
	/**
	 * 
	 * @author Francois
	 * @date 12 janv. 2011;
	 */
	public class MainMenu extends Sprite implements Disposable{

		private var _buttons:Vector.<FeverButton>;
		private var _menus:Vector.<IMenuContent>;
		private var _buttonToMenu:Dictionary;
		private var _currentMenu:DisplayObjectContainer;
		private var _currentButton:FeverButton;
		private var _map:MapEngine;
		private var _specials:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MainMenu</code>.
		 */
		public function MainMenu(map:MapEngine) {
			_map = map;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Closes the currently opened content.
		 */
		public function close(all:Boolean = false):void {
			if(!all) {
				if(_currentMenu != null) {
					IMenuContent(_currentMenu).close();
					removeChild(_currentMenu);
				}
			}else{
				var i:int, len:int;
				len = _menus.length;
				for(i = 0; i < len; ++i) {
					if(_menus[i] != null && contains(_menus[i] as DisplayObject)){
						_menus[i].close();
						removeChild(_menus[i] as DisplayObject);
					}
				}
			}
			_currentMenu = null;
			_currentButton = null;
			computePositions();
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			var i:int, len:int;
			len = _buttons.length;
			for(i = 0; i < len; ++i) {
				_buttons[i].addEventListener(NurunButtonEvent.OVER, rollOverHandler);
				_buttons[i].addEventListener(NurunButtonEvent.OUT, rollOutHandler);
				_buttons[i].addEventListener(MouseEvent.CLICK, clickItemHandler);
				if(_menus[i] != null){
					_menus[i].removeEventListener(Event.OPEN, menuAskForOpenHandler);
					_menus[i].removeEventListener(Event.RESIZE, computePositions);
				}
			}
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.removeEventListener(MouseEvent.CLICK, clickStageHandler);
			stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			var config:XML = new XML(Config.getVariable("menus"));
			var nodes:XMLList = config.child("menu");
			var i:int, len:int, tabI:int, item:FeverButton, clazz:Class, menu:IMenuContent;
			
			//FORCE INCLUDES
			MenuFilters;
			MenuNavigation;
			MenuSearch;
			MenuTracker;
			MenuMessage;
			MenuHelp;
			MenuLangSelector;
			MenuZoom;
			
			len = nodes.length();
			_buttons = new Vector.<FeverButton>(len, true);
			_menus = new Vector.<IMenuContent>(len, true);
			_buttonToMenu = new Dictionary();
			_specials = new Dictionary();
			for(i = 0; i < len; ++i) {
				if(nodes[i].@special == "logout" && DataManager.getInstance().muxxuContext) continue;
				
				clazz = getDefinitionByName(nodes[i].@icon) as Class;
				item = addChild(new FeverButton(nodes[i][0], new clazz(), false)) as FeverButton;
				item.height = 25;
				item.iconSpacing = 5;
				if(String(nodes[i][0]).length == 0) {
					item.iconAlign = IconAlign.CENTER;
				}else{
					item.contentMargin = new Margin(0, 0, 0, 0, 15, 15);
				}
				item.tabIndex = tabI++;
				if(nodes[i].@special != undefined) {
					_specials[item] = nodes[i].@special;
				}
				_buttons[i] = item;
				if(nodes[i].@content != undefined) {
					clazz = getDefinitionByName(nodes[i].@content) as Class;
					menu = new clazz() as IMenuContent;
					menu.map = _map;
					menu.addEventListener(Event.RESIZE, computePositions);
					tabI = menu.setTabIndexes(tabI) + 1;
					_menus[i] = menu;
					_buttonToMenu[item] = menu;
					item.mapEvents(menu as InteractiveObject);
					item.addEventListener(NurunButtonEvent.OVER, rollOverHandler);
					item.addEventListener(NurunButtonEvent.OUT, rollOutHandler);
					menu.addEventListener(Event.OPEN, menuAskForOpenHandler);
				}
				item.addEventListener(MouseEvent.CLICK, clickItemHandler);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, clickStageHandler);
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
			computePositions();
		}
		
		/**
		 * Patch for a fuckin' bug.
		 * The first button doesn't detects rollout so it never closes.
		 */
		private function keyFocusChangeHandler(event:FocusEvent):void {
			if(stage != null && stage.focus != null && _currentMenu != null && !_currentMenu.contains(event.relatedObject as DisplayObject)) {
				close();
			}
		}
		
		/**
		 * Called when an item is clicked.
		 */
		private function clickItemHandler(event:MouseEvent):void {
			var special:String = _specials[event.target];
			switch(special) {
				case "logout":
					DataManager.getInstance().logout();
					break;
				default:
			}
		}
		
		/**
		 * Called when the stage is clicked
		 */
		private function clickStageHandler(event:MouseEvent):void {
			if(_currentMenu != null && !IMenuContent(_currentMenu).locked && !AbstractMenuContent(_currentMenu).background.hitTestPoint(stage.mouseX, stage.mouseY)) {
				close(true);
			}
		}
		
		/**
		 * Called when a component is rolled over
		 */
		private function rollOverHandler(event:NurunButtonEvent):void {
			if(_buttonToMenu[event.currentTarget] != _currentMenu) close();
			_currentButton = event.currentTarget as FeverButton;
			_currentMenu = _buttonToMenu[_currentButton] as DisplayObjectContainer;
			addChildAt(_currentMenu, 0);
			IMenuContent(_currentMenu).open();
			computePositions();
		}
		
		/**
		 * Called when a component is rolled out.
		 */
		private function rollOutHandler(event:NurunButtonEvent):void {
			if(_currentMenu == null
			 	|| IMenuContent(_currentMenu).locked
				|| AbstractMenuContent(_currentMenu).background.hitTestPoint(stage.mouseX, stage.mouseY)
				|| (stage != null && stage.focus != null && _currentMenu.contains(stage.focus as DisplayObject)))
					return;
				
			close();
		}
		
		/**
		 * Called if a menu asks for opening.
		 */
		private function menuAskForOpenHandler(event:Event):void {
			if(_currentMenu != null && event.currentTarget != _currentMenu) close();
//			_currentButton = event.currentTarget as FeverButton;
			_currentMenu = event.currentTarget as DisplayObjectContainer;
			for (var i:* in _buttonToMenu) {
				if(_buttonToMenu[i] == _currentMenu) {
					_currentButton = i;
					break;
				}
			}
			addChildAt(_currentMenu, 0);
			IMenuContent(_currentMenu).open();
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			var i:int, len:int;
			len = numChildren;
			for(i = 0; i < len; ++i) {
				if(getChildAt(i) is Validable) {
					Validable(getChildAt(i)).validate();
				}
			}
			PosUtils.hPlaceNext(-1, ArrayUtils.toArray(_buttons));
			
			if(_currentMenu != null) {
				_currentMenu.x = _currentButton.x;// + 10;
				if(_currentMenu.x + _currentMenu.width > stage.stageWidth) {
					_currentMenu.x = stage.stageWidth - _currentMenu.width;
				}
				_currentMenu.y = 24;
			}
		}
		
	}
}