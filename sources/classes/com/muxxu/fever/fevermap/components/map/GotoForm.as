package com.muxxu.fever.fevermap.components.map {

	import com.nurun.core.lang.Disposable;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.ZoneInput;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
		private var _submit:FeverButton;
		/**
		 * Gets the X coordinate value
		 */
		public function get posX():int { return _input.xValue; }
		
		/**
		 * Gets the Y coordinate value
		 */
		public function get posY():int { return _input.yValue; }


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
			
		}
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
		
		}

			_input.validate();
			