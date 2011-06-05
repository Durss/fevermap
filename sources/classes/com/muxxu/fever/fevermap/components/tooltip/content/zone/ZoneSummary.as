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
	import flash.utils.getDefinitionByName;		/**	 * Displays a summary infos of a zone.	 * 	 * @author Francois	 * @date 9 nov. 2010;	 */	public class ZoneSummary extends Sprite {				private var _enemiesBt:BaseButton;
		
		private const _BT_WIDTH:int = 19;
		private var _items:Vector.<FeverToggleButton>;
		private var _itemsCtn:Sprite;
		private var _asterisk:CssTextField;
								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ZoneSumary</code>.		 */		public function ZoneSummary() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */
				/* ****** *		 * PUBLIC *		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(data:MapEntry):void {
			visible = true;
			
			while(_itemsCtn.numChildren > 0) { _itemsCtn.removeChildAt(0); }

			if(data == null) {
				if(contains(_enemiesBt)) removeChild(_enemiesBt);				if(contains(_asterisk)) removeChild(_asterisk);
				return;
			}
			var enemies:String = data.rawData.@e;
			if(enemies.length > 0) {
				_enemiesBt.text = enemies.split(",").length.toString();//oooooh oui j'ai osé :')
			}else{
				_enemiesBt.text = "0";
			}
			addChild(_enemiesBt);			addChild(_asterisk);
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
		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {
			visible		= false;
			_itemsCtn	= addChild(new Sprite()) as Sprite;			_enemiesBt	= addChild(new BaseButton("0", "enemiesInfos", null, new EnemyIconGraphic())) as BaseButton;
			_asterisk	= addChild(new CssTextField("tooltipAsterisk")) as CssTextField;
			
			_asterisk.text = Label.getLabel("tooltipAsterisk");
			//			_enemiesBt.icon.scaleX = 1.5;//			_enemiesBt.icon.scaleY = 1.5;			_enemiesBt.iconAlign = IconAlign.RIGHT;			_enemiesBt.textAlign = TextAlign.LEFT;			_enemiesBt.iconSpacing = 5;			_enemiesBt.enabled = false;						var i:int, len:int, item:FeverToggleButton, icon:Sprite, iconClass:Class;			_items = new Vector.<FeverToggleButton>();			len = Constants.ITEMS+1;			for(i = 1; i < len; ++i) {				iconClass	= getDefinitionByName("com.muxxu.fever.graphics.Item" + i + "Graphic") as Class;				icon		= new iconClass() as Sprite;
//				icon.scaleX	= 1.5;//				icon.scaleY	= 1.5;				item		= createToggleButton(icon);
				item.mouseEnabled= false;				_items.push(item);			}						computePositions();		}				/**		 * Resizes and replaces the elements.		 */
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
			button.iconAlign = IconAlign.CENTER;			button.icon.alpha= 1;
			button.width	= _BT_WIDTH * icon.scaleX;
			button.height	= _BT_WIDTH * icon.scaleY;
			return button; 
		}			}}