package com.muxxu.fever.fevermap.components {	import flash.filters.DropShadowFilter;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.configuration.Config;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.MouseEvent;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.nurun.structure.environnement.label.Label;
		/**	 * 	 * @author Francois	 * @date 15 nov. 2010;	 */
	public class FeedbackButton extends FeverButton {

								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>FeedbackView</code>.		 */		public function FeedbackButton() {			super(Label.getLabel("feedback"));			style = "feedback";			contentMargin = new Margin(5, 5, 5, 5);			filters = [new DropShadowFilter(0,0,0x000000,.4,6,6,1.5,3)];		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */		override protected function clickHandler(event:MouseEvent):void {			navigateToURL(new URLRequest(Config.getPath("feedbackUrl")));			super.clickHandler(event);		}			}}