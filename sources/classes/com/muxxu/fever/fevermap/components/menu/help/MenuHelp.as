package com.muxxu.fever.fevermap.components.menu.help {
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 févr. 2011;
	 */
	public class MenuHelp extends AbstractMenuContent implements IMenuContent {

		private var _legals:CssTextField;
		private var _help:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuHelp</code>.
		 */
		public function MenuHelp() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function setTabIndexes(value:int):int { return value; }


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			_help = _container.addChild(new CssTextField("help")) as CssTextField;
			_legals = _container.addChild(new CssTextField("legals")) as CssTextField;
			
			_help.text = Label.getLabel("help");
			_legals.text = Label.getLabel("legals");
			
			_help.width = 415;
			_legals.width = 415;
			
			_legals.y = Math.round(_help.height + 30);
			
			computePositions();
		}
		
	}
}