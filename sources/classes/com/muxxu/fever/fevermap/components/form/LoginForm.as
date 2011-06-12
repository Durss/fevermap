package com.muxxu.fever.fevermap.components.form {
	public class LoginForm extends Sprite implements Disposable {

//		private static const FILTER_LOGOUT:ColorMatrixFilter = new ColorMatrixFilter([1.24,0.57,-1.01,0,-67.3,-0.3,0.84,0.26,0,-67.3,0.67,-0.93,1.06,0,-67.3,0,0,0,1,0]);

		private var _background:BackToolTipGraphic;
		private var _uid:FeverLabeledInput;
		private var _pubkey:FeverLabeledInput;
		private var _submitBt:FeverButton;
		private var _spin:SpinGraphic;
		private var _container:Sprite;
		private var _rememberMe:FeverCheckBox;
		private var _title:CssTextField;
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
		}
			_uid.input.textfield.maxChars = 25;
			_pubkey.input.width = 150;
			_uid.input.validate();
			_pubkey.input.tabIndex = 2;
			filters = [new DropShadowFilter(0,0,0x000000,.4,6,6,1.5,3)];
			_uid.input.addEventListener(FormComponentEvent.SUBMIT, clickSubmitHandler);
			_rememberMe.addEventListener(Event.CHANGE, changeValueHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_COMPLETE, loginResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_ERROR, loginResultHandler);
		}
		
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		private function changeValueHandler(event:Event):void {
			SharedObjectManager.getInstance().rememberMe = _rememberMe.selected;
		
		private function clickSubmitHandler(event:Event):void {
			_spin.visible = true;
			_submitBt.enabled = false;
			TweenLite.to(_container, .2, {alpha:.35});
		}
		
		private function computePositions(event:Event = null):void {
			PosUtils.vPlaceNext(5, _uid, _pubkey, _rememberMe, _submitBt, _error);
			_rememberMe.x = Math.max(_pubkey.width, _uid.width) - _pubkey.input.width;
			_container.x = margin;
			_container.y = margin;
			_background.height	= _submitBt.y + _submitBt.height + margin*2;
			_container.graphics.drawRect(-margin, -margin, _background.width, _title.height + margin * 2);
			_container.graphics.endFill();
		private function loginResultHandler(event:DataManagerEvent):void {
				stage.focus = null;
			}else{