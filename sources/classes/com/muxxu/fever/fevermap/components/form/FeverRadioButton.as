package com.muxxu.fever.fevermap.components.form {

	import com.muxxu.fever.graphics.FeverRadioButtonGraphic;
	import com.muxxu.fever.graphics.FeverRadioButtonSelectedGraphic;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.form.RadioButton;

	import flash.filters.DropShadowFilter;
		/**	 * 	 * @author Francois	 * @date 11 nov. 2010;	 */	public class FeverRadioButton extends RadioButton {										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeverRadioButton</code>.		 */		public function FeverRadioButton(label:String, cssDefault:String = "radioButtonLabelUnselected", cssSelected:String = "radioButtonLabelSelected") {			super(label, cssDefault, cssSelected, new FeverRadioButtonGraphic(), new FeverRadioButtonSelectedGraphic());
						activateDefaultVisitor();
			yLabelOffset = -2;
						filters = [new DropShadowFilter(2,45,0x000000,.4,3,3,1,3)];
			accept(new CssVisitor());		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */
			}}