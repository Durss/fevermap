package com.muxxu.fever.fevermap.components.form {
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.data.DataManager;
	import flash.geom.Point;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import flash.events.Event;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Sprite;
	
	public class ObjectsFlagger extends Sprite {

		private var _items:Vector.<ObjectChecker>;
		private var _area:Point;
		
		public function populate(data:MapEntry, area:Point):void {
			while(numChildren > 0) {
				ObjectChecker(getChildAt(0)).unSelect();
				removeChildAt(0);
			
			var objects:String = data.rawData.@i;
			
		}

		/**
		private function changeSelectionHandler(event:Event):void {
			len = numChildren;
			for(i = 0; i < len; ++i) {
				if(ObjectChecker(getChildAt(i)).selected) {
				}
		}
		