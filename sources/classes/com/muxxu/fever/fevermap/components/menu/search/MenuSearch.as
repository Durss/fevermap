package com.muxxu.fever.fevermap.components.menu.search {

	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 janv. 2011;
	 */
	public class MenuSearch extends AbstractMenuContent implements IMenuContent {

		private var _userForm:MenuSearchFriendForm;
		private var _objectsForm:MenuSearchObjects;
		private var _pathFinder:MenuSearchPath;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuSearch</code>.
		 */
		public function MenuSearch() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets if th emenu is locked (to prevent from closing)
		 */
		override public function get locked():Boolean {
			return _pathFinder.opened;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			value = _objectsForm.setTabIndexes(value);
			value = _userForm.setTabIndexes(value);
			value = _pathFinder.setTabIndexes(value);
			return value;
		}
		

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_objectsForm = _container.addChild(new MenuSearchObjects(390)) as MenuSearchObjects;
			_userForm	= _container.addChild(new MenuSearchFriendForm(390)) as MenuSearchFriendForm;
			_pathFinder = _container.addChild(new MenuSearchPath(390)) as MenuSearchPath;
			
			_userForm.addEventListener(Event.RESIZE, resizeFormHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.GET_USERS_ON_COMPLETE, getUsersCompleteHandler);
			
			computePositions();
		}
		
		/**
		 * Called when the form is resized.
		 */
		private function resizeFormHandler(event:Event):void {
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions():void {
			PosUtils.vPlaceNext(20, _objectsForm, _userForm, _pathFinder);
			
			super.computePositions();
			
			//Redraw manually due to scrollpane sizes...
			_back.graphics.clear();
			_back.graphics.lineStyle(0, 0x271714, 1);
			_back.graphics.beginFill(0x412720, 1);
			_back.graphics.drawRect(0, 0, 400, Math.round(_pathFinder.y + _pathFinder.height  + _margin*2) - 1);
			_back.graphics.endFill();
		}
		
		/**
		 * Called when friends loading complete.
		 */
		private function getUsersCompleteHandler(event:DataManagerEvent):void {
			dispatchEvent(new Event(Event.OPEN));
		}
		
	}
}