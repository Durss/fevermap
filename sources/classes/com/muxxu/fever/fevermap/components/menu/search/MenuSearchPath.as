package com.muxxu.fever.fevermap.components.menu.search {

	import gs.TweenLite;

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.FeverCombobox;
	import com.muxxu.fever.fevermap.components.form.ZoneInput;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.graphics.CheckBmp;
	import com.muxxu.fever.graphics.Item41Graphic;
	import com.muxxu.fever.graphics.Item45Graphic;
	import com.muxxu.fever.graphics.PinEndGraphic;
	import com.muxxu.fever.graphics.PinStartGraphic;
	import com.muxxu.fever.graphics.PoustyGraphic;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.muxxu.fever.graphics.UncheckBmp;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.form.events.ListEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 13 mars 2011;
	 */
	public class MenuSearchPath extends Sprite {
		
		private var _width:int;
		private var _title:CssTextField;
		private var _startInput:ZoneInput;
		private var _endInput:ZoneInput;
		private var _pinStart:PinStartGraphic;
		private var _pinEnd:PinEndGraphic;
		private var _startTitle:CssTextField;
		private var _endTitle:CssTextField;
		private var _poustyBT:FeverButton;
		private var _submitBt:FeverButton;
		private var _spin:SpinGraphic;
		private var _clearBt:FeverButton;
		private var _objectCb:FeverCombobox;
		private var _cancelCb:FeverButton;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuSearchPath</code>.
		 */
		public function MenuSearchPath(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets if the combobox is opened or not
		 */
		public function get opened():Boolean { return _objectCb.opened || _objectCb.list.height > 0; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			_startInput.tabIndex = value++;
			_poustyBT.tabIndex = value++;
			_endInput.tabIndex = value++;
			_submitBt.tabIndex = value++;
			return value;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_title = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_startInput = addChild(new ZoneInput()) as ZoneInput;
			_endInput = addChild(new ZoneInput()) as ZoneInput;
			_pinStart = addChild(new PinStartGraphic()) as PinStartGraphic;
			_pinEnd = addChild(new PinEndGraphic()) as PinEndGraphic;
			_startTitle = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_endTitle = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_poustyBT = addChild(new FeverButton("", new PoustyGraphic())) as FeverButton;
			_submitBt = addChild(new FeverButton("", new Bitmap(new CheckBmp(NaN,NaN)))) as FeverButton;
			_clearBt = addChild(new FeverButton("", new Bitmap(new UncheckBmp(NaN,NaN)))) as FeverButton;
			_cancelCb = addChild(new FeverButton("", new Bitmap(new UncheckBmp(NaN, NaN)))) as FeverButton;
			_objectCb = addChild(new FeverCombobox("", false, true, true)) as FeverCombobox;
			_spin = new SpinGraphic();
			
			_title.text = Label.getLabel("menuSearchPathTitle");
			_startTitle.text = Label.getLabel("menuSearchPathStartLabel");
			_endTitle.text = Label.getLabel("menuSearchPathEndLabel");
			_submitBt.text = Label.getLabel("menuSearchPathSubmit");
			_clearBt.text = Label.getLabel("menuSearchPathClear");
			
			_submitBt.textAlign = TextAlign.CENTER;
			_clearBt.textAlign = TextAlign.CENTER;
			_submitBt.icon.filters = [new DropShadowFilter(0,0,0,.5,4,4,2)];
			_clearBt.icon.filters = [new DropShadowFilter(0,0,0,.5,4,4,2)];
			
			_cancelCb.contentMargin = new Margin(0, 0, 0, 0);
			_cancelCb.iconAlign = IconAlign.RIGHT;
			_cancelCb.visible = false;
			
			_title.background = true;
			_title.backgroundColor = 0;
			_title.width = _width;
			_title.text = Label.getLabel("menuSearchPathTitle");
			
			_poustyBT.iconAlign = IconAlign.CENTER;
			_poustyBT.textAlign = TextAlign.CENTER;
			
			_startInput.xValue = SharedObjectManager.getInstance().playerPosition.x;
			_startInput.yValue = SharedObjectManager.getInstance().playerPosition.y;
			
			var i:int, iconClass:Class, clazz:Class;
			for(i = 13; i < 41; ++i) {
				clazz = getDefinitionByName("com.muxxu.fever.graphics.Item" + i + "Graphic") as Class;
				_objectCb.addSkinnedItem("", i-1, "comboboxItem", new clazz());
			}
			_objectCb.addSkinnedItem("", 45, "comboboxItem", new Item45Graphic());
			
			FeverButton(_objectCb.button).icon = new Item41Graphic();
			
			computePositions();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			_startInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_endInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_objectCb.addEventListener(ListEvent.SELECT_ITEM, selectObjectHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.PATH_FINDER_NO_PATH_FOUND, dataHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.PATH_FINDER_PATH_FOUND, dataHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_startInput.validate();
			_endInput.validate();
			_submitBt.validate();
			
			_objectCb.height = _endInput.height;
			_objectCb.validate();
			
			_poustyBT.height = _startInput.height;
			_poustyBT.validate();
			
			PosUtils.vPlaceNext(2, _title, _startInput, _endInput);
			PosUtils.hPlaceNext(2, _pinStart, _startTitle, _startInput);
			PosUtils.hPlaceNext(2, _pinEnd, _endTitle, _endInput);
			
			_pinStart.y = _startTitle.y = _poustyBT.y = _startInput.y;
			_pinEnd.y = _endTitle.y = _objectCb.y = _endInput.y;
			
			_endInput.x = _startInput.x = Math.max(_endInput.x, _startInput.x);
			PosUtils.hPlaceNext(5, _startInput, _poustyBT);
			PosUtils.hPlaceNext(5, _endInput, _objectCb);
			
			_cancelCb.x = _objectCb.x + _objectCb.width - 2;
			_cancelCb.y = _objectCb.y;
			_cancelCb.height = _objectCb.height;
			
			_spin.x = _submitBt.x + _submitBt.width * .5;
			_spin.y = _submitBt.y + _submitBt.height * .5;
			
			_clearBt.width = _submitBt.width = (_width - 10) *.5;
			_clearBt.y = _submitBt.y = Math.round(_endInput.y + _endInput.height + 5);
			_clearBt.x = Math.round(_width - _clearBt.width);
		}
		
		/**
		 * Called when a component is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _poustyBT) {
				_startInput.xValue = SharedObjectManager.getInstance().playerPosition.x;
				_startInput.yValue = SharedObjectManager.getInstance().playerPosition.y;
			}else if(event.target == _submitBt) {
				submitHandler(null);
			}else if(event.target == _clearBt) {
				DataManager.getInstance().clearPath();
			}else if(event.target == _cancelCb) {
				_objectCb.unSelectAll();
				_cancelCb.visible = false;
				_endInput.enabled = true;
				FeverButton(_objectCb.button).icon = new Item41Graphic();
			}
		}
		
		/**
		 * Submits the form
		 */
		private function submitHandler(event:FormComponentEvent):void {
			if(_submitBt.enabled) {
				if(isNaN(_startInput.xValue) || isNaN(_startInput.yValue)) {
					_startInput.alpha = 1;
					TweenLite.from(_startInput, .5, {alpha:0});
					return;
				}
				if((isNaN(_endInput.xValue) || isNaN(_endInput.yValue)) && _objectCb.selectedData == null) {
					_endInput.alpha = 1;
					TweenLite.from(_endInput, .5, {alpha:0});
					return;
				}
				_submitBt.enabled = false;
				DataManager.getInstance().findPath(_startInput.position, _endInput.position, _objectCb.selectedData);
				addChild(_spin);
			}
		}
		
		/**
		 * Called on server's callback
		 */
		private function dataHandler(event:DataManagerEvent):void {
			_submitBt.enabled = true;
			if(contains(_spin)) removeChild(_spin);
		}
		
		/**
		 * Called when an object is selected on the combobox
		 */
		private function selectObjectHandler(event:ListEvent):void {
			_cancelCb.visible = true;
			_endInput.enabled = false;
		}
		
	}
}