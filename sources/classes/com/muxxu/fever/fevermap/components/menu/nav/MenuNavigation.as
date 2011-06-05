package com.muxxu.fever.fevermap.components.menu.nav {

	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import flash.events.MouseEvent;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.map.GotoForm;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.graphics.PoustyGraphic;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.geom.Point;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 janv. 2011;
	 */
	public class MenuNavigation extends AbstractMenuContent implements IMenuContent {

		private var _title:CssTextField;
		private var _form:GotoForm;
		private var _pousty:FeverButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuNavigation</code>.
		 */
		public function MenuNavigation() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		




		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			value = _form.setTabIndex(value) + 1;
			_pousty.tabIndex = value;
			return value;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			super.dispose();
			
			_form = null;
			
			_form.removeEventListener(FormComponentEvent.SUBMIT, changeFormValueHandler);
			_pousty.removeEventListener(MouseEvent.CLICK, clickSubmitHandler);
		}

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_title		= _container.addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_form		= _container.addChild(new GotoForm()) as GotoForm;
			_pousty		= _container.addChild(new FeverButton(Label.getLabel("menuNavCenterPousty"), new PoustyGraphic())) as FeverButton;
			
			_title.text	= Label.getLabel("menuNavTitle");
			
			_form.addEventListener(FormComponentEvent.SUBMIT, changeFormValueHandler);
			_pousty.addEventListener(MouseEvent.CLICK, clickSubmitHandler);
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions():void {
			_pousty.validate();
			_form.validate();
			PosUtils.vPlaceNext(5, _title, _form, _pousty);
			
			_form.y -= 2;
			
			super.computePositions();
		}
		
		/**
		 * Called when the form is submited.
		 */
		private function changeFormValueHandler(event:FormComponentEvent):void {
			_map.centerOn(new Point(_form.posX, _form.posY));
		}

		private function clickSubmitHandler(event:MouseEvent):void {
			_map.centerOn(SharedObjectManager.getInstance().playerPosition);
		}
		
	}
}