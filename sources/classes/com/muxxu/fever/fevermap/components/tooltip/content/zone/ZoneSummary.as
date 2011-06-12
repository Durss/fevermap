package com.muxxu.fever.fevermap.components.tooltip.content.zone {

	import com.muxxu.fever.fevermap.data.Constants;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.pos.PosUtils;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import flash.display.DisplayObject;
	import com.muxxu.fever.fevermap.components.button.FeverToggleButton;
	import com.muxxu.fever.graphics.EnemyIconGraphic;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;

	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
		
		private const _BT_WIDTH:int = 19;
		private var _items:Vector.<FeverToggleButton>;
		private var _itemsCtn:Sprite;
		private var _asterisk:CssTextField;
		
		
		/**
		 * Populates the component
		 */
		public function populate(data:MapEntry):void {
			visible = true;
			
			while(_itemsCtn.numChildren > 0) { _itemsCtn.removeChildAt(0); }

			if(data == null) {
				if(contains(_enemiesBt)) removeChild(_enemiesBt);
				return;
			}
			var enemies:String = data.rawData.@e;
			if(enemies.length > 0) {
				_enemiesBt.text = enemies.split(",").length.toString();//oooooh oui j'ai osé :')
			}else{
				_enemiesBt.text = "0";
			}
			addChild(_enemiesBt);
			computePositions();
			
			var itemsStr:String = data.rawData.@i;
			
			if(itemsStr.length == 0 || !SharedObjectManager.getInstance().spoil){
				computePositions();
				return;
			}
			
			var i:int, len:int, indexes:Array, item:FeverToggleButton, items:Array;
			indexes = itemsStr.split(",");
			len = indexes.length;
			items = [];
			for(i = 0; i < len; ++i) {
				item = _items[parseInt(indexes[i])];
				items.push(item);
				_itemsCtn.addChild(item);
			}
			PosUtils.hDistribute(items, (_BT_WIDTH + 1) * 10 - 1);
			computePositions();
		}
			visible		= false;
			_itemsCtn	= addChild(new Sprite()) as Sprite;
			_asterisk	= addChild(new CssTextField("tooltipAsterisk")) as CssTextField;
			
			_asterisk.text = Label.getLabel("tooltipAsterisk");
			
//				icon.scaleX	= 1.5;
				item.mouseEnabled= false;
		private function computePositions():void {
			if(_itemsCtn.numChildren > 0) {
				PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _enemiesBt, _itemsCtn, _asterisk);
				PosUtils.vPlaceNext(0, _enemiesBt, _itemsCtn, _asterisk);
			}else{
				PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _enemiesBt, _asterisk);
				PosUtils.vPlaceNext(0, _enemiesBt, _asterisk);
			}
		}

		/**
		 * Creates a toggle button
		 */
		private function createToggleButton(icon:DisplayObject):FeverToggleButton {
			var button:FeverToggleButton = new FeverToggleButton("", icon, icon);
			button.iconAlign = IconAlign.CENTER;
			button.width	= _BT_WIDTH * icon.scaleX;
			button.height	= _BT_WIDTH * icon.scaleY;
			return button; 
		}