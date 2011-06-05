package com.muxxu.fever.fevermap.events {
	import flash.events.Event;
	
	/**
	 * Event fired by SharedObjectManager singleton
	 * 
	 * @author Francois
	 * @date 31 janv. 2011;
	 */
	public class SharedObjectManagerEvent extends Event {
		
		public static const DATA_UPDATE:String = "dataUpdate";
		public static const TIMER_SAVE_START:String = "timerSaveStart";
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SharedObjectManagerEvent</code>.
		 */
		public function SharedObjectManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes a clone of the event object.
		 */
		override public function clone():Event {
			return new SharedObjectManagerEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}