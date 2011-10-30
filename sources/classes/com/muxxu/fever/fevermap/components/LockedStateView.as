package com.muxxu.fever.fevermap.components {
	import gs.TweenLite;

	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 24 oct. 2011;
	 */
	public class LockedStateView extends Sprite {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LockedStateView</code>.
		 */
		public function LockedStateView() {
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
			alpha = 0;
			visible = false;
			buttonMode = false;
			mouseChildren = false;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOCK, lockStateChangeHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.UNLOCK, lockStateChangeHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		private function lockStateChangeHandler(event:DataManagerEvent):void {
			TweenLite.to(this, .25, {autoAlpha:DataManager.getInstance().locked? 1 : 0});
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
				
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			graphics.clear();
			graphics.beginFill(0xffffff, .25);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
		}
		
	}
}