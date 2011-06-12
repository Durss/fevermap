package com.muxxu.fever.fevermap.components.form {
	import com.nurun.components.text.CssTextField;
	import com.muxxu.fever.fevermap.components.tooltip.content.zone.ZoneEditor;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.nurun.utils.number.NumberUtils;
	import flash.utils.Dictionary;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.display.DisplayObject;
	import com.nurun.components.button.IconAlign;
	import com.muxxu.fever.fevermap.components.button.FeverToggleButton;
	import gs.easing.Quad;
	import flash.events.Event;
	import gs.TweenLite;
	import com.muxxu.fever.graphics.ArrowRightGraphic;
	import com.muxxu.fever.graphics.ArrowLeftGraphic;
	import com.muxxu.fever.graphics.ArrowBottomGraphic;
	import com.muxxu.fever.graphics.ArrowTopGraphic;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class ZoneForm extends Sprite {

		private const _BT_WIDTH:int = 19;
		private var _opened:Boolean;
		private var _mask:Shape;
		private var _container:Sprite;
		private var _arrowTop:FeverToggleButton;
		private var _arrowBottom:FeverToggleButton;
		private var _arrowLeft:FeverToggleButton;
		private var _arrowRight:FeverToggleButton;
		private var _closing:Boolean;
		private var _data:MapEntry;
		private var _revisions:RevisionsPaginator;
		private var _map:ZoneEditor;
		private var _titleArrows:CssTextField;

		


		
		override public function get width():Number { return _opened ? _mask.width : 0; }
			arrows = new Vector.<FeverToggleButton>();
			arrows.push(_arrowTop, _arrowLeft, _arrowBottom, _arrowRight);
			len = arrows.length;
			var dirs:Number = parseInt(str, 2);
			if(dirs >> 1 & 0x1 == 1) _arrowBottom.selected = true;
			if(dirs >> 2 & 0x1 == 1) _arrowLeft.selected = true;
			if(dirs >> 3 & 0x1 == 1) _arrowTop.selected = true;
			_opened = true;

		/**
		public function reset():void {
			_arrowLeft.selected = false;
			_arrowRight.selected = false;
			_arrowTop.selected = false;
		}


			_container	= addChild(new Sprite()) as Sprite;
			_mask.graphics.beginFill(0xff0000, 0);
			_container.mask = _mask;
		}
		
		}

		/**
		private function keyUpHandler(event:KeyboardEvent):void {
			if(!_opened) return;
			if(event.keyCode == Keyboard.UP) {
				_arrowTop.selected = !_arrowTop.selected;
			} else if(event.keyCode == Keyboard.DOWN) {
				_arrowBottom.selected = !_arrowBottom.selected;
			} else if(event.keyCode == Keyboard.RIGHT) {
				_arrowRight.selected = !_arrowRight.selected;
			} else if(event.keyCode == Keyboard.LEFT) {
				_arrowLeft.selected = !_arrowLeft.selected;

		}

		/**
		private function createToggleButton(icon:DisplayObject):FeverToggleButton {
			var button:FeverToggleButton = new FeverToggleButton("", icon, icon);
		}


		/**
			var w:int = Math.max((_BT_WIDTH + 2) * 10 - 2, _map.width);
			PosUtils.vPlaceNext(10, _revisions, _map);
			_arrowBottom.y = Math.round(_arrowLeft.y + _arrowLeft.height);
			_container.graphics.clear();
				_container.graphics.drawRect(_titleArrows.x, py, availW, _revisions.height - py);
				_container.graphics.endFill();
		private function revisionChangeHandler(event:Event):void {
			var data:Revision = _revisions.revision;
			_map.populateRevision(data);
		}
		