package com.muxxu.fever.fevermap.components.menu {

	import flash.events.IEventDispatcher;
	import com.muxxu.fever.fevermap.components.map.MapEngine;
	/**
	 * @author Francois
	 */
	public interface IMenuContent extends IEventDispatcher {
		
		/**
		 * Gives the map reference.
		 */
		function set map(value:MapEngine):void;
		
		/**
		 * Sets the tab index start value of the content.
		 */
		function setTabIndexes(value:int):int;
		
		/**
		 * Called when opened.
		 */
		function open():void;
		
		/**
		 * Called when closed.
		 */
		function close():void;
		
		/**
		 * Gets if th emenu is locked (to prevent from closing)
		 */
		function get locked():Boolean;
		
	}
}
