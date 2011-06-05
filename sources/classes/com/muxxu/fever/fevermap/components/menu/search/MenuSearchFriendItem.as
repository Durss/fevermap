package com.muxxu.fever.fevermap.components.menu.search {

	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.vo.User;
	import com.muxxu.fever.graphics.Item22Graphic;
	import com.muxxu.fever.graphics.MuxxuIconGraphic;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 févr. 2011;
	 */
	public class MenuSearchFriendItem extends Sprite {

		private var _data:User;
		private var _mapButton:BaseButton;
		private var _profileButton:BaseButton;
		private var _index:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuSearchFriendItem</code>.
		 */
		public function MenuSearchFriendItem(data:User, index:int) {
			_index = index;
			_data = data;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			removeEventListener(MouseEvent.CLICK, clickHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_profileButton = addChild(new BaseButton(_data.name, "menuContentMessageText", null, new Bitmap(new MuxxuIconGraphic(NaN, NaN)))) as BaseButton;
			_mapButton = addChild(new BaseButton("["+_data.pos.x+"]["+_data.pos.y+"]", "menuContentMessageText", null, new Item22Graphic())) as BaseButton;
			
			_profileButton.iconAlign = IconAlign.LEFT;
			_mapButton.iconAlign = IconAlign.LEFT;
			
			_profileButton.height = 15;
			_mapButton.height = 15;
			
			_profileButton.validate();
			_mapButton.validate();
			
			PosUtils.hPlaceNext(15, _profileButton, _mapButton);
			
			graphics.beginFill((_index%2==0)? 0 : 0xffffff, .2);
			graphics.drawRect(0, 0, 184, 15);
			graphics.endFill();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when the component is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _profileButton) {
				var url:String = Config.getPath("profileURL").replace(/\$\{UID\}/gi, _data.id);
				navigateToURL(new URLRequest(url), "_blank");
			}else{
				DataManager.getInstance().openZone(_data.pos);
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
	}
}