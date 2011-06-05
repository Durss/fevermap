package com.muxxu.fever.fevermap.components.menu.filters {

	import com.muxxu.fever.fevermap.components.form.FeverCheckBox;
	import com.muxxu.fever.fevermap.components.form.FeverRadioButton;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.form.events.FormComponentGroupEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.array.ArrayUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 janv. 2011;
	 */
	public class MenuFilters extends AbstractMenuContent implements IMenuContent {

		private var _showGotObjects:FeverCheckBox;
		private var _spoilBt:FeverCheckBox;
		private var _spoilGlowBt:FeverCheckBox;
		private var _diffObjects:FeverCheckBox;
//		private var _importFlags:FeverButton;
		private var _group:FormComponentGroup;
		private var _renderModeTitle:CssTextField;
		private var _isInit:Boolean;
		private var _btToRenderModeId:Dictionary;
		private var _renderModeButtons : Vector.<FeverRadioButton>;

		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuFilters</code>.
		 */
		public function MenuFilters(isInit:Boolean = false) {
			_isInit = isInit;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			_spoilBt.tabIndex = value++;
			_showGotObjects.tabIndex = value++;
			_spoilGlowBt.tabIndex = value++;
			_diffObjects.tabIndex = value++;
			var i:int, len:int;
			len = _renderModeButtons.length;
			for(i = 0; i < len; ++i) {
				_renderModeButtons[i].tabIndex = value ++;
			}
			return value;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			super.dispose();
			
			_spoilBt.removeEventListener(Event.CHANGE, changeSelectionHandler);
			_spoilGlowBt.removeEventListener(Event.CHANGE, changeSelectionHandler);
			_diffObjects.removeEventListener(Event.CHANGE, changeSelectionHandler);
			_showGotObjects.removeEventListener(Event.CHANGE, changeSelectionHandler);
			_group.removeEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			
			_group.dispose();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			var renderModes:Array = [Label.getLabel("renderModeClassic"),
									Label.getLabel("renderModePath"),
									Label.getLabel("renderModePopulation"),
									Label.getLabel("renderModeDifficulty"),
									Label.getLabel("renderModeFreedIslands")];
			_group = new FormComponentGroup();
			
			_showGotObjects = _container.addChild(new FeverCheckBox(Label.getLabel("showGotObjects"))) as FeverCheckBox;
			_spoilBt = _container.addChild(new FeverCheckBox(Label.getLabel("spoilObjects"))) as FeverCheckBox;
			_spoilGlowBt = _container.addChild(new FeverCheckBox(Label.getLabel("spoilGlow"))) as FeverCheckBox;
			_diffObjects = _container.addChild(new FeverCheckBox(Label.getLabel("diffObjects"))) as FeverCheckBox;
			_renderModeTitle = _container.addChild(new CssTextField("menuContentTitle")) as CssTextField;
//			_importFlags = _container.addChild(new FeverButton(Label.getLabel("importFlags"), new Item11Graphic())) as FeverButton;
			
//			_importFlags.textAlign = TextAlign.CENTER;
			
			_renderModeTitle.text = Label.getLabel("renderModeTitle");
			var i:int, len:int, bt:FeverRadioButton;
			len = renderModes.length;
			_btToRenderModeId = new Dictionary();
			_renderModeButtons = new Vector.<FeverRadioButton>(len, true);
			for(i = 0; i < len; ++i) {
				bt = _container.addChild(new FeverRadioButton(renderModes[i])) as FeverRadioButton;
				_btToRenderModeId[bt] = i;
				_group.add(bt);
				_renderModeButtons[i] = bt;
				bt.x = 10;
				bt.validate();
			}
			
			if(_isInit) {
				_container.removeChild(_renderModeTitle);
				len = _renderModeButtons.length;
				for(i = 0; i < len; ++i) {
					_container.removeChild(_renderModeButtons[i]);
				}
//				_container.removeChild(_importFlags);
			}

			_showGotObjects.selected = SharedObjectManager.getInstance().sgObjects;
			_spoilBt.selected = SharedObjectManager.getInstance().spoil;
			_spoilGlowBt.selected = SharedObjectManager.getInstance().spoilGlow;
			_diffObjects.selected = SharedObjectManager.getInstance().diffObjects;
			_group.selectItem(_renderModeButtons[SharedObjectManager.getInstance().renderMode]);
			_diffObjects.enabled = _spoilGlowBt.selected;
			_showGotObjects.enabled = _spoilBt.selected;
			
			_spoilBt.addEventListener(Event.CHANGE, changeSelectionHandler);
			_spoilGlowBt.addEventListener(Event.CHANGE, changeSelectionHandler);
			_diffObjects.addEventListener(Event.CHANGE, changeSelectionHandler);
			_showGotObjects.addEventListener(Event.CHANGE, changeSelectionHandler);
			_group.addEventListener(FormComponentGroupEvent.CHANGE, changeSelectionHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
			
			_back.visible = !_isInit;
		}
		
		/**
		 * Called when a button is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
//			if(event.target == _importFlags) {
//				DataManager.getInstance().importFlags();
//			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions():void {
			
			_showGotObjects.validate();
			_spoilBt.validate();
			_spoilGlowBt.validate();
			_diffObjects.validate();
			
//			_importFlags.width = _fullScreen.width = Math.max(_showGotObjects.width, _spoilBt.width, _spoilGlowBt.width, _diffObjects.width);
//			_importFlags.validate();

			PosUtils.vPlaceNext(3, _spoilBt, _showGotObjects, _spoilGlowBt, _diffObjects, _renderModeTitle);
			_renderModeTitle.y += 10;
			PosUtils.vPlaceNext(3, _renderModeTitle, ArrayUtils.toArray(_renderModeButtons));
//			PosUtils.vPlaceNext(10, _renderMode3, _importFlags);

			super.computePositions();
		}




		// __________________________________________________________ CLICK HANDLERS


		/**
		 * Called when a form value changes.
		 */
		private function changeSelectionHandler(event:Event):void {
			SharedObjectManager.getInstance().spoil = _spoilBt.selected;
			SharedObjectManager.getInstance().spoilGlow = _spoilGlowBt.selected;
			SharedObjectManager.getInstance().diffObjects = _diffObjects.selected;
			SharedObjectManager.getInstance().sgObjects = _showGotObjects.selected;
			SharedObjectManager.getInstance().renderMode = _btToRenderModeId[_group.selectedItem];
			_diffObjects.enabled = _spoilGlowBt.selected;
			_showGotObjects.enabled = _spoilBt.selected;
			if(!_isInit) {
				DataManager.getInstance().renderMap();
			}
		}
		
	}
}