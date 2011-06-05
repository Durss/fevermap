package com.muxxu.fever.fevermap.components.scrollbar {

	import com.muxxu.fever.fevermap.components.scrollbar.skin.FeverScrollBarSkin;
	import com.muxxu.fever.graphics.ScrollbarRectScrollerGraphic;
	import com.muxxu.fever.graphics.ScrollbarRectTrackGraphic;
	import com.nurun.components.scroll.scroller.scrollbar.Scrollbar;
	import com.nurun.core.lang.Disposable;

	/**	 * Creates a scrollbar.<br>	 * <br>	 * This class is used to create all the kinds of scrollbar in the website.<br>	 * To create a specific scrollbar use the <code>type</code> parameter of the	 * constructor that specifies the kind of scrollbar to create.	 * 	 * @example The following code creates a scrollbar with a combo box skin.	 * 	<listing version="3.0">	 * 	var scroll:FeverScrollBar = new FeverScrollBar();	 * 	</listing>	 * s	 * @author  Francois DURSUS for Nurun	 */	public class FeverScrollBar extends Scrollbar implements Disposable {								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeverScrollBar</code>.		 */		public function FeverScrollBar() {			super(new FeverScrollBarSkin(new ScrollbarRectScrollerGraphic(), new ScrollbarRectTrackGraphic()));			scrollerMinSize = 30;		}
						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */						/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Makes the component garbage collectable.		 */		override public function dispose():void {			super.dispose();		}								/* ******* *		 * PRIVATE *		 * ******* */	}}