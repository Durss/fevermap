package com.muxxu.fever.fevermap.components.button {

	import com.muxxu.fever.graphics.ButtonSkin;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	/**	 * Displays a classic button.	 * 	 * @author  Francois	 */	public class FeverButton extends BaseButton {										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeverButton</code>.		 */		public function FeverButton(label:String, icon:DisplayObject = null, setClickVisitor:Boolean = true) {			super(label, "button", new ButtonSkin(), icon);			var fv:FrameVisitor = new FrameVisitor();			var opts:FrameVisitorOptions = new FrameVisitorOptions("out", "over", setClickVisitor? "down" : "over", "disable");			opts.enableFrameFrom = "out";			opts.disableFrameFrom = "disable";			fv.addTarget(background as MovieClip, opts);			if(icon != null && icon is MovieClip){				fv.addTarget(icon as MovieClip, opts);			}			contentMargin = new Margin(5, 5, 5, 5);
			accept(fv);			if(setClickVisitor) accept(new CssVisitor());			textAlign = TextAlign.LEFT;			iconAlign = IconAlign.LEFT;			iconSpacing = 3;			filters = [new DropShadowFilter(2,45,0x000000,.4,3,3,1,3)];		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */	}}