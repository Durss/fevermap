package com.muxxu.fever.fevermap.components.map {
	import flash.events.Event;
	
	/**
	 * Event fired by a MapEntry instance.
	 * 
	 * @author Francois
	 * @date 23 nov. 2010;
	 */
	public class MapEntryEvent extends Event {

		public static const UPDATE:String = "mapEntryUpdate";
		
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MapEntryEvent</code>.
		 */
		public function MapEntryEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
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
			return new MapEntryEvent(type, bubbles, cancelable);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}