package com.muxxu.fever.fevermap.components.menu.message {

	import com.nurun.utils.string.StringUtils;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.ColorChecker;
	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.AppMessage;
	import com.muxxu.fever.graphics.InputSkinGraphic;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableTextField;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	
	/**
	 * 
	 * @author Francois
	 * @date 27 janv. 2011;
	 */
	public class MenuMessageForm extends Sprite implements Disposable {

		private var _title:CssTextField;
		private var _textfield:ScrollableTextField;
		private var _scrollpane:ScrollPane;
		private var _group:FormComponentGroup;
		private var _submit:FeverButton;
		private var _backInput:InputSkinGraphic;
		private var _colorCheckers:Vector.<ColorChecker>;
		private var _colors:Array;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuMessageForm</code>.
		 */
		public function MenuMessageForm(colors:Array) {
			_colors = colors;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		public function setTabIndexes(value:int):int {
			_textfield.tabIndex = value ++;
			var i:int, len:int;
			len = _colorCheckers.length;
			for(i = 0; i < len; ++i) {
				_colorCheckers[i].tabIndex = value ++;
			}
			_submit.tabIndex = value ++;
			return value;
		}



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
		 	
			_submit.removeEventListener(MouseEvent.CLICK, clickSubmitHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.ADD_MESSAGE_COMPLETE, addMessageResultHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.ADD_MESSAGE_ERROR, addMessageResultHandler);
			
			_group.dispose();
			_colorCheckers = null;
			_colors = null;
		 }


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_group = new FormComponentGroup();
			_backInput = addChild(new InputSkinGraphic()) as InputSkinGraphic;
			_title = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_textfield = new ScrollableTextField("", "menuContentMessageTextInput");
			_scrollpane = addChild(new ScrollPane(_textfield, new FeverScrollBar())) as ScrollPane;
			_submit = addChild(new FeverButton(Label.getLabel("menuMessageSubmit"))) as FeverButton;
			
			_title.text = Label.getLabel("menuMessageAddTitle");
			_title.background = true;
			_title.backgroundColor = 0;
			_title.width = 400;
			
			_scrollpane.width = 399;
			_scrollpane.height = 70;
			_scrollpane.y = Math.round(_title.height + 1);
			_scrollpane.autoHideScrollers = true;
			
			_textfield.type = TextFieldType.INPUT;
			_textfield.maxChars = 500;
			
			_backInput.x = _scrollpane.x;
			_backInput.y = _scrollpane.y - 1;
			_backInput.width = _scrollpane.width + 1;
			_backInput.height = _scrollpane.height + 2;
			
			var i:int, len:int, px:int, py:int, item:ColorChecker;
			len = _colors.length;
			py = _scrollpane.y + _scrollpane.height + 10;
			_colorCheckers = new Vector.<ColorChecker>();
			for(i = 0; i < len; ++i) {
				if(i == len-1 && SharedObjectManager.getInstance().uid != "89") continue;
				
				item = addChild(new ColorChecker(_colors[i])) as ColorChecker;
				if(px == 0) {
					px = Math.round((_scrollpane.width - (len * (item.width + 10) - 10)) * .5);
				}
				item.x = px;
				item.y = py;
				item.value = i;
				px += item.width + 10;
				_group.add(item);
				_colorCheckers.push(item);
			}
			
			if(SharedObjectManager.getInstance().uid == "89") {
				item.selected = true;
			}else{
				_colorCheckers[0].selected = true;
			}
			_submit.y = Math.round(item.y + item.height + 10);
			PosUtils.hCenterIn(_submit, _scrollpane);
			
			_submit.addEventListener(MouseEvent.CLICK, clickSubmitHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_MESSAGE_COMPLETE, addMessageResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_MESSAGE_ERROR, addMessageResultHandler);
			_textfield.addEventListener(FocusEvent.FOCUS_IN, focusChangeTextFieldHandler);
			_textfield.addEventListener(FocusEvent.FOCUS_OUT, focusChangeTextFieldHandler);
		}
		
		/**
		 * Called when the textfield receives or looses the focus.
		 */
		private function focusChangeTextFieldHandler(event:FocusEvent):void {
			_textfield.text = _textfield.text.replace(Label.getLabel("menuMessageTooShort"), "").replace(/</gi,"&lt;").replace(/(>)/gi,"&gt;");
			if(stage != null && stage.displayState == StageDisplayState.FULL_SCREEN) {
				stage.displayState = StageDisplayState.NORMAL;
				var message:AppMessage = new AppMessage();
				message.dynamicPopulate(Label.getLabel("autoExitFullScreenHelp"), 1);
				DataManager.getInstance().showMessage(message);
			}
		}
		
		/**
		 * Called when the submit button is clicked
		 */
		private function clickSubmitHandler(event:MouseEvent):void {
			_textfield.text = _textfield.text.replace(Label.getLabel("menuMessageTooShort"), "");
			if(StringUtils.trim(_textfield.text.replace(/\&lt;/gi,"<").replace(/&gt;/gi,">")).length < 10 || _textfield.text == Label.getLabel("menuMessageTooShort")) {
				_textfield.text = _textfield.text.replace(/</gi,"&lt;").replace(/(>)/gi,"&gt;") + Label.getLabel("menuMessageTooShort");
			}else{
				_submit.enabled = false;
				DataManager.getInstance().addMessage(_textfield.text, int(ColorChecker(_group.selectedItem).value));
			}
		}
		
		/**
		 * Called when a message sending completes or fails.
		 */
		private function addMessageResultHandler(event:DataManagerEvent):void {
			_submit.enabled = true;
			if(event.type == DataManagerEvent.ADD_MESSAGE_COMPLETE) {
				_textfield.text = "";
			}
		}
		
	}
}