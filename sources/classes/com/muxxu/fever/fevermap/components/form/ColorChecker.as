package com.muxxu.fever.fevermap.components.form {
	
	/**
	 * 
	 * @author Francois
	 * @date 27 janv. 2011;
	 */
	public class ColorChecker extends FeverRadioButton {
		
		private var _color:uint;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ColorChecker</code>.
		 */
		public function ColorChecker(color:uint) {
			_color = color;
			super("");
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function get width():Number {
			return icon.x + icon.width + 5 + icon.height * 1.5;
		}

		public function get color():uint {
			return _color;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function computePositions():void {
			super.computePositions();
			
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, icon.width + icon.height, icon.height);
			graphics.beginFill(_color, 1);
			graphics.drawRect(icon.width + 3, 0, icon.height * 1.5, icon.height);
			graphics.endFill();
		}
		
	}
}