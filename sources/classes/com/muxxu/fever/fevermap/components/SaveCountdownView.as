package com.muxxu.fever.fevermap.components {
	import flash.events.MouseEvent;
	import com.muxxu.fever.fevermap.components.tooltip.content.TTTextContent;
	import com.muxxu.fever.fevermap.vo.ToolTipMessage;
	import com.muxxu.fever.fevermap.components.tooltip.ToolTip;
	import gs.TweenLite;
	import gs.easing.Linear;

	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.events.SharedObjectManagerEvent;
	import com.muxxu.fever.graphics.CountDownGraphic;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;

	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	/**
	 * 
	 * @author Francois
	 */
	public class SaveCountdownView extends Sprite {
		private var _countDown:CountDownGraphic;
		private var _title:CssTextField;
		private var _tooltip:ToolTip;
		private var _message : ToolTipMessage;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SaveCountdownView</code>.
		 */
		public function SaveCountdownView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_countDown = addChild(new CountDownGraphic()) as CountDownGraphic;
			_title = addChild(new CssTextField("countdownTitle")) as CssTextField;
			_tooltip = new ToolTip();
			_message = new ToolTipMessage(new TTTextContent(false, Label.getLabel("countedownDetails")));
			
			_title.text = Label.getLabel("countdownTitle");
			
			_countDown.stop();
			visible = false;
			
			computePositions();
			
			_title.filters = _countDown.filters = [new DropShadowFilter(0,0,0,1,6,6,1,3)];
			
			SharedObjectManager.getInstance().addEventListener(SharedObjectManagerEvent.TIMER_SAVE_START, startSaveHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * Called when the component is rolled over.
		 */
		private function rollOverHandler(event:MouseEvent):void {
			addChild(_tooltip);
			_tooltip.open(_message);
			_tooltip.x = Math.round((_title.width - _tooltip.width) * .5);
			_tooltip.y = -_tooltip.height;
		}

		/**
		 * Called when the component is rolled out.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			removeChild(_tooltip);
			_tooltip.close();
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions():void {
			_countDown.x = Math.round((_title.width - _countDown.width) * .5);
			_countDown.y = Math.round(_title.height + 2);
			
			graphics.clear();
			graphics.beginFill(0xffffff, .2);
			graphics.drawRect(0, 0, _title.width, _countDown.y + _countDown.height);
			graphics.endFill();
		}
		
		/**
		 * Called when starting the save timer.
		 */
		private function startSaveHandler(event:SharedObjectManagerEvent):void {
			_countDown.gotoAndStop(1);
			alpha = 0;
			TweenLite.killTweensOf(this);
			TweenLite.killTweensOf(_countDown);
			TweenLite.to(_countDown, 5, {frame:_countDown.totalFrames, ease:Linear.easeNone, delay:1, onComplete:onTweenComplete});
			TweenLite.to(this, .25, {autoAlpha:1, delay:1});
		}
		
		/**
		 * Called when animation completes.
		 */
		private function onTweenComplete():void {
			TweenLite.to(this, .25, {autoAlpha:0});
		}
		
	}
}