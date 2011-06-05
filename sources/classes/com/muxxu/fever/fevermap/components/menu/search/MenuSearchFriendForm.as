package com.muxxu.fever.fevermap.components.menu.search {

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.FeverInput;
	import com.muxxu.fever.fevermap.components.form.ZoneInput;
	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.User;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 févr. 2011;
	 */
	public class MenuSearchFriendForm extends Sprite {

		private var _title:CssTextField;
		private var _nameInput:FeverInput;
		private var _nameInfo:CssTextField;
		private var _submit:FeverButton;
		private var _zoneInput:ZoneInput;
		private var _zoneInfo:CssTextField;
		private var _resultsCtn:ScrollableDisplayObject;
		private var _scrollpane:ScrollPane;
		private var _resultTitle:CssTextField;
		private var _width:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuSearchFriendForm</code>.
		 */
		public function MenuSearchFriendForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number {
			if(_resultsCtn.content.numChildren > 0) {
				return _scrollpane.y + _scrollpane.height;
			}else{
				return _resultTitle.y;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			_nameInput.tabIndex = value++;
			_zoneInput.tabIndex = value++;
			_submit.tabIndex = value;
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
			_nameInfo = addChild(new CssTextField("menuContentTitleSmall")) as CssTextField;
			_nameInput = addChild(new FeverInput()) as FeverInput;
			_zoneInfo = addChild(new CssTextField("menuContentTitleSmall")) as CssTextField;
			_zoneInput = addChild(new ZoneInput()) as ZoneInput;
			_submit = addChild(new FeverButton(Label.getLabel("menuSearchUserSubmit"))) as FeverButton;
			_resultsCtn = new ScrollableDisplayObject();
			_scrollpane = addChild(new ScrollPane(_resultsCtn, new FeverScrollBar(), new FeverScrollBar())) as ScrollPane;
			_resultTitle = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			
			_scrollpane.autoHideScrollers = true;
			_title.background = true;
			_title.backgroundColor = 0;
			_title.width = _width;
			
			_title.text = Label.getLabel("menuSearchUserTitle");
			_nameInfo.text = Label.getLabel("menuSearchUserNameDetails");
			_zoneInfo.text = Label.getLabel("menuSearchUserZoneDetails");
			_resultTitle.text = Label.getLabel("menuSearchResultTitle");
			
			_zoneInput.alpha = .5;
			_resultTitle.visible = false;
			_resultTitle.background = true;
			_resultTitle.backgroundColor = 0;
			
			computePositions();
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_nameInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_zoneInput.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_nameInput.addEventListener(FocusEvent.FOCUS_IN, focusChangeHandler);
			_zoneInput.addEventListener(FocusEvent.FOCUS_IN, focusChangeHandler);
			
			DataManager.getInstance().addEventListener(DataManagerEvent.GET_USERS_ON_COMPLETE, getUsersCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.GET_USERS_ON_ERROR, getUsersErrorHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_nameInput.width = 200;
			_zoneInput.width = 100;
			_scrollpane.width = _width;
			_resultTitle.width = _width;
			if(_resultsCtn.content.numChildren == 0) {
				_scrollpane.height = 0;
			}else{
				_scrollpane.height = Math.min(300, _resultsCtn.content.height + 20);
			}
			_nameInput.validate();
			_zoneInput.validate();
			_submit.validate();
			_scrollpane.validate();
			
			PosUtils.vPlaceNext(2, _title, _nameInfo, _nameInput, _zoneInfo, _zoneInput, _submit, _resultTitle, _scrollpane);
			_resultTitle.y += 10;
			_scrollpane.y += 10;
		}
		
		/**
		 * Called when focus changes
		 */
		private function focusChangeHandler(event:FocusEvent):void {
			if(event.currentTarget == _nameInput) {
				_nameInput.alpha = 1;
				_zoneInput.alpha = .5;
				_zoneInput.reset();
			}else if(event.currentTarget == _zoneInput) {
				_zoneInput.alpha = 1;
				_nameInput.alpha = .5;
				_nameInput.text = "";
			}
		}
		
		/**
		 * Called when user submits the form.
		 */
		private function submitHandler(event:Event):void {
			if(!_submit.enabled) return;
			_submit.enabled = false;
			if(_nameInput.alpha == 1) {
				DataManager.getInstance().getUserOn(0, 0, _nameInput.text);
			}else{
				DataManager.getInstance().getUserOn(_zoneInput.xValue, _zoneInput.yValue);
			}
		}
		
		/**
		 * Called when users are available
		 */
		private function getUsersCompleteHandler(event:DataManagerEvent):void {
			_submit.enabled = true;
			while(_resultsCtn.content.numChildren > 0) {
				if(_resultsCtn.content.getChildAt(0) is Disposable) Disposable(_resultsCtn.content.getChildAt(0)).dispose();
				_resultsCtn.content.removeChildAt(0);
			}
			var i:int, len:int, item:MenuSearchFriendItem, items:Vector.<User>, itemsList:Vector.<MenuSearchFriendItem>;
			items = event.items;
			len = Math.min(200, items.length);
			itemsList = new Vector.<MenuSearchFriendItem>(len, true);
			for(i = 0; i < len; ++i) {
				item = _resultsCtn.addChild(new MenuSearchFriendItem(items[i], i)) as MenuSearchFriendItem;
				itemsList[i] = item;
			}
			
			_resultTitle.visible = true;
			
			if(len > 1) PosUtils.vDistribute(itemsList, Math.ceil(item.height) * Math.ceil(len * .5), 2);
			if(len == 0) {
				var tf:CssTextField = _resultsCtn.addChild(new CssTextField("tooltipContentError")) as CssTextField;
				tf.text = Label.getLabel("menuSearchNoResults");
			}
			computePositions();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called if users loading fails.
		 */
		private function getUsersErrorHandler(event:DataManagerEvent):void {
			_submit.enabled = true;
		}
		
	}
}