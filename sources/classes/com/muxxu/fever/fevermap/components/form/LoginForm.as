package com.muxxu.fever.fevermap.components.form {	import gs.TweenLite;	import com.muxxu.fever.fevermap.components.button.FeverButton;	import com.muxxu.fever.fevermap.data.DataManager;	import com.muxxu.fever.fevermap.data.SharedObjectManager;	import com.muxxu.fever.fevermap.events.DataManagerEvent;	import com.muxxu.fever.graphics.BackToolTipGraphic;	import com.muxxu.fever.graphics.SpinGraphic;	import com.muxxu.fever.graphics.WarningIconGraphic;	import com.nurun.components.button.BaseButton;	import com.nurun.components.button.IconAlign;	import com.nurun.components.button.TextAlign;	import com.nurun.components.form.events.FormComponentEvent;	import com.nurun.components.text.CssTextField;	import com.nurun.core.lang.Disposable;	import com.nurun.structure.environnement.label.Label;	import com.nurun.utils.pos.PosUtils;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.filters.DropShadowFilter;		/**	 * 	 * @author Francois	 * @date 7 nov. 2010;	 */
	public class LoginForm extends Sprite implements Disposable {

//		private static const FILTER_LOGOUT:ColorMatrixFilter = new ColorMatrixFilter([1.24,0.57,-1.01,0,-67.3,-0.3,0.84,0.26,0,-67.3,0.67,-0.93,1.06,0,-67.3,0,0,0,1,0]);

		private var _background:BackToolTipGraphic;
		private var _uid:FeverLabeledInput;
		private var _pubkey:FeverLabeledInput;
		private var _submitBt:FeverButton;
		private var _spin:SpinGraphic;
		private var _container:Sprite;
		private var _rememberMe:FeverCheckBox;
		private var _title:CssTextField;		private var _error:BaseButton;		private var _help:CssTextField;										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>LoginForm</code>.		 */		public function LoginForm() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {			_submitBt.removeEventListener(MouseEvent.CLICK, clickSubmitHandler);			_uid.input.removeEventListener(FormComponentEvent.SUBMIT, clickSubmitHandler);			_pubkey.input.removeEventListener(FormComponentEvent.SUBMIT, clickSubmitHandler);			_rememberMe.removeEventListener(Event.CHANGE, changeValueHandler);			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_COMPLETE, loginResultHandler);			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_ERROR, loginResultHandler);			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			stage.removeEventListener(Event.RESIZE, computePositions);						while(_container.numChildren > 0) {				if(_container.getChildAt(0) is Disposable) Disposable(_container.getChildAt(0)).dispose();				_container.removeChildAt(0);			}						while(numChildren > 0) {				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();				removeChildAt(0);			}						filters = [];
		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_background	= addChild(new BackToolTipGraphic()) as BackToolTipGraphic;			_container	= addChild(new Sprite()) as Sprite;			_spin		= addChild(new SpinGraphic()) as SpinGraphic;			_title		= _container.addChild(new CssTextField("tooltipContent")) as CssTextField;			_error		= _container.addChild(new BaseButton("", "tooltipContentError", null, new WarningIconGraphic())) as BaseButton;			_uid		= _container.addChild(new FeverLabeledInput(Label.getLabel("loginFormLogin"))) as FeverLabeledInput;			_pubkey		= _container.addChild(new FeverLabeledInput(Label.getLabel("loginFormPassword"))) as FeverLabeledInput;			_rememberMe	= _container.addChild(new FeverCheckBox(Label.getLabel("loginFormRememberMe"))) as FeverCheckBox;			_submitBt	= _container.addChild(new FeverButton(Label.getLabel("loginFormSubmit"))) as FeverButton;			_help		= _container.addChild(new CssTextField("tooltipContent")) as CssTextField;						_rememberMe.selected = SharedObjectManager.getInstance().rememberMe;			if(_rememberMe.selected) {				_uid.input.text = SharedObjectManager.getInstance().uid;				_pubkey.input.text = SharedObjectManager.getInstance().pubkey;			}			_title.text = Label.getLabel("loginFormTitle");			_help.text = Label.getLabel("loginFormHelp");						_spin.visible = false;			_error.enabled = false;			_error.visible = false;			_error.iconAlign = IconAlign.LEFT;			_error.textAlign = TextAlign.LEFT;			
			_uid.input.textfield.maxChars = 25;						_pubkey.input.textfield.maxChars = 25;			_pubkey.input.textfield.displayAsPassword = true;						_uid.input.width = 150;
			_pubkey.input.width = 150;			
			_uid.input.validate();			_pubkey.input.validate();						_uid.input.tabIndex = 1;
			_pubkey.input.tabIndex = 2;			_rememberMe.tabIndex = 3;			_submitBt.tabIndex = 5;			
			filters = [new DropShadowFilter(0,0,0x000000,.4,6,6,1.5,3)];						_submitBt.addEventListener(MouseEvent.CLICK, clickSubmitHandler);
			_uid.input.addEventListener(FormComponentEvent.SUBMIT, clickSubmitHandler);			_pubkey.input.addEventListener(FormComponentEvent.SUBMIT, clickSubmitHandler);
			_rememberMe.addEventListener(Event.CHANGE, changeValueHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_COMPLETE, loginResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_ERROR, loginResultHandler);			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
				/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}		/**		 * Called when a checkbox selection state changes.		 */
		private function changeValueHandler(event:Event):void {
			SharedObjectManager.getInstance().rememberMe = _rememberMe.selected;		}
				/**		 * Called when submit button is clicked.		 */
		private function clickSubmitHandler(event:Event):void {
			_spin.visible = true;
			_submitBt.enabled = false;
			TweenLite.to(_container, .2, {alpha:.35});			DataManager.getInstance().logIn(_uid.value, _pubkey.value);
		}
				/**		 * Resizes and replaces the elements.		 */
		private function computePositions(event:Event = null):void {			_container.graphics.clear();			_submitBt.validate();			_help.y = Math.round(_title.y + _title.height + 10);			_uid.y = Math.round(_help.y + _help.height + 10);			PosUtils.hAlign(PosUtils.H_ALIGN_RIGHT, 0, _uid, _pubkey);
			PosUtils.vPlaceNext(5, _uid, _pubkey, _rememberMe, _submitBt, _error);			PosUtils.hCenterIn(_submitBt, this);
			_rememberMe.x = Math.max(_pubkey.width, _uid.width) - _pubkey.input.width;						var margin:int = 5;
			_container.x = margin;
			_container.y = margin;			_background.width	= _container.width + margin*2;
			_background.height	= _submitBt.y + _submitBt.height + margin*2;						if(_error.text.length > 0) {				_background.height += _error.height + 5;			}						PosUtils.centerIn(_spin, _background);			_spin.x += _spin.width * .5;			_spin.y += _spin.height * .5;						x = Math.round((stage.stageWidth - _background.width) * .5);			y = Math.round((stage.stageHeight - _background.height) * .5);						_container.graphics.beginFill(0, 1);
			_container.graphics.drawRect(-margin, -margin, _background.width, _title.height + margin * 2);
			_container.graphics.endFill();		}		/**		 * Called when login completes or fails.		 */
		private function loginResultHandler(event:DataManagerEvent):void {			if(event.type == DataManagerEvent.LOGIN_COMPLETE) {
				stage.focus = null;
			}else{				_error.visible = true;				_error.text = Label.getLabel("loginError"+event.resultCode);			}			_spin.visible = false;			_submitBt.enabled = true;			TweenLite.to(_container, .2, {alpha:1});			computePositions();		}	}}