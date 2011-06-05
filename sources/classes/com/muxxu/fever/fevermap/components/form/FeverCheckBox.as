package com.muxxu.fever.fevermap.components.form {

	import com.muxxu.fever.graphics.FeverCheckBoxGraphic;
	import com.muxxu.fever.graphics.FeverCheckBoxSelectedGraphic;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.form.Checkbox;

	import flash.filters.DropShadowFilter;
		/**	 * 	 * @author Francois	 * @date 11 nov. 2010;	 */	public class FeverCheckBox extends Checkbox {										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeverCheckBox</code>.		 */		public function FeverCheckBox(label:String, cssDefault:String = "checkboxLabelUnselected", cssSelected:String = "checkboxLabelSelected") {			super(label, cssDefault, cssSelected, new FeverCheckBoxGraphic(), new FeverCheckBoxSelectedGraphic());
						activateDefaultVisitor();
			yLabelOffset = -2;
						filters = [new DropShadowFilter(2,45,0x000000,.4,3,3,1,3)];
			accept(new CssVisitor());		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */
			}}