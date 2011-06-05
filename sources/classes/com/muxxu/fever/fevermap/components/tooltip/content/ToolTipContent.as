package com.muxxu.fever.fevermap.components.tooltip.content {
	import flash.events.IEventDispatcher;

	/**
	 * Should be implemented by all the tooltip's contents.
	 * 
	 * @author Francois
	 */
	public interface ToolTipContent extends IEventDispatcher {
		
		/**
		 * Makes the component garbage collectable.
		 */
		function dispose():void;
		
		/**
		 * Gets if the content asks for tooltip's lock
		 */
		function get locked():Boolean;
		
	}
}
