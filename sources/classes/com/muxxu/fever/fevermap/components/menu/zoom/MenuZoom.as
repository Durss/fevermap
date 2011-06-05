package com.muxxu.fever.fevermap.components.menu.zoom {

	import com.nurun.components.vo.Margin;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.map.MapEngine;
	import com.muxxu.fever.fevermap.components.map.MapEngineEvent;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.graphics.Item21Graphic;
	import com.muxxu.fever.graphics.ZoomButtonGraphic;
	import com.muxxu.fever.graphics.ZoomButtonSelectedGraphic;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 12 mars 2011;
	 */
	public class MenuZoom extends AbstractMenuContent implements IMenuContent {

		private var _buttons:Vector.<ToggleButton>;
		private var _buttonToZoom:Dictionary;
		private var _group:FormComponentGroup;
		private var _fullScreenBt:FeverButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuZoom</code>.
		 */
		public function MenuZoom() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function setTabIndexes(value:int):int {
			return value;
		}
		/**
		 * Sets the map's reference.
		 */
		override public function set map(value:MapEngine):void {
			_map = value;
			_map.addEventListener(MapEngineEvent.ZOOM_CHANGED, zoomChangedHandler);
			zoomChangedHandler();
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			super.dispose();
			_group.dispose();
			_buttons = null;
			_buttonToZoom = null;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			var icons:Array = ["IslandZoom1Graphic", "IslandZoom2Graphic", "IslandZoom3Graphic", "IslandZoom4Graphic", "IslandZoom5Graphic"];
			var i:int, len:int, py:int, bt:ToggleButton, clazz:Class, icon:DisplayObject;
			len = icons.length;
			py = 2;
			
			_fullScreenBt = _container.addChild(new FeverButton(Label.getLabel("toggleFullScreen"), new Item21Graphic())) as FeverButton;
			_fullScreenBt.y = py;
			_fullScreenBt.textAlign = TextAlign.RIGHT;
			_fullScreenBt.contentMargin = new Margin(10, 10, 10, 10);
			_fullScreenBt.iconSpacing = 10;
			_fullScreenBt.validate();
			py += _fullScreenBt.height + 10;
			
			_buttons = new Vector.<ToggleButton>(len, true);
			_buttonToZoom = new Dictionary();
			_group = new FormComponentGroup();
			for(i = 0; i < len; ++i) {
				clazz = getDefinitionByName("com.muxxu.fever.graphics."+icons[i]) as Class;
				icon = new clazz();
				if(icon is MovieClip) MovieClip(icon).stop();
				
				bt = _container.addChild(new ToggleButton("x"+(i+1), "menuContentZoom", "menuContentZoom_selected", new ZoomButtonGraphic(), new ZoomButtonSelectedGraphic(), icon, icon)) as ToggleButton;
				bt.accept(new CssVisitor());
				bt.iconAlign = IconAlign.CENTER;
				bt.textAlign = TextAlign.LEFT;
				bt.y = py;
				bt.width = Math.max(120, _fullScreenBt.width);
				bt.height = 50;
				py += bt.height + 5;
				applyDefaultFrameVisitorNoTween(bt, bt.defaultBackground, bt.selectedBackground);
				_buttons[i] = bt;
				_buttonToZoom[bt] = i + 1;
				_group.add(bt);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Called when zoom value changes
		 */
		private function zoomChangedHandler(event:MapEngineEvent = null):void {
			_group.selectItem(_buttons[_map.zoomLevel - 1]);
		}
		
		/**
		 * Called when a button is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _fullScreenBt) {
				if(stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE){
					stage.displayState = StageDisplayState.NORMAL;
				}else{
					try { 
						stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					}catch(error:Error) {
						stage.displayState = StageDisplayState.FULL_SCREEN;
					}
				}
			}else{
				_map.zoomLevel = _buttonToZoom[event.target];
			}
		}
		
	}
}