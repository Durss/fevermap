package com.muxxu.fever.fevermap.components.form {

		/**

		
		public function validate():void {
			_inputX.validate();
		}
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
		}
