package com.muxxu.fever.fevermap.events {
	import flash.events.Event;
		private var _area:Rectangle;
		private var _items:*;
		private var _message:AppMessage;
		public function DataManagerEvent(type:String, resultCode:int = 0, area:Rectangle = null, items:* = null, message:AppMessage = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			_message = message;
			_items = items;
			return new DataManagerEvent(type, resultCode, area, items, message, bubbles, cancelable);
		}