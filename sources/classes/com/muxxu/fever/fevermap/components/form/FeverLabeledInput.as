package com.muxxu.fever.fevermap.components.form {	import com.nurun.utils.pos.PosUtils;
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
		/**	 * 	 * @author Francois	 * @date 7 nov. 2010;	 */
	public class FeverLabeledInput extends Sprite {

		private var _label:CssTextField;
		private var _input:FeverInput;
		private var _labelStr:String;
										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeverLabeledInput</code>.		 */
		public function FeverLabeledInput(label:String) {
			_labelStr = label;
			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the input's value		 */
		public function get value():String { return _input.text; }		/**		 * Gets the input's reference.		 */		public function get input():FeverInput { return _input; }				/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_label = addChild(new CssTextField("inputLabel")) as CssTextField;
			_input = addChild(new FeverInput()) as FeverInput;
						_label.text = _labelStr;
						computePositions();		}				/**		 * Resizes and replaces the elements.		 */
		private function computePositions():void {
			PosUtils.hPlaceNext(10, _label, _input);
			_input.validate();
		}			}}