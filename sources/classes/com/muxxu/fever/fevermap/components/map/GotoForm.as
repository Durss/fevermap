package com.muxxu.fever.fevermap.components.map {

	import com.nurun.core.lang.Disposable;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.ZoneInput;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
		/**	 * 	 * @author Francois	 */	public class GotoForm extends Sprite implements Disposable {				private var _input:ZoneInput;
		private var _submit:FeverButton;								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>GotoForm</code>.		 */		public function GotoForm() {			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */
		/**
		 * Gets the X coordinate value
		 */
		public function get posX():int { return _input.xValue; }
		
		/**
		 * Gets the Y coordinate value
		 */
		public function get posY():int { return _input.yValue; }

		/* ****** *		 * PUBLIC *		 * ****** */		/**
		 * Forces the rendering
		 */
		public function validate():void {
			computePositions();
		}
		
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndex(value:int):int {
			_input.tabIndex = value ++;
			_submit.tabIndex = value;
			return value;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_submit.removeEventListener(MouseEvent.CLICK, submitHandler);
			_input.removeEventListener(FormComponentEvent.SUBMIT, submitHandler);
			
		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_input		= addChild(new ZoneInput()) as ZoneInput;			_submit		= addChild(new FeverButton(Label.getLabel("mapEngineGotoSubmit"))) as FeverButton;			
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);			_input.addEventListener(FormComponentEvent.SUBMIT, submitHandler);						computePositions();		}
				/**		 * Called when the form is submitted.		 */		private function submitHandler(event:Event):void {			if(isNaN(_input.xValue) || isNaN(_input.yValue)) return;			dispatchEvent(new FormComponentEvent(FormComponentEvent.SUBMIT));
		}
		/**		 * Resize and replace the elements.		 */		private function computePositions():void {			_input.width = 200;
			_input.validate();
						_submit.x = Math.round(_input.x + _input.width + 5);			_submit.height = _input.height;			_submit.validate();		}	}}