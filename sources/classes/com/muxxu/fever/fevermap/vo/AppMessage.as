package com.muxxu.fever.fevermap.vo {	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.core.lang.vo.XMLValueObject;		/**	 * 	 * @author Francois	 * @date 11 nov. 2010;	 */
	public class AppMessage implements XMLValueObject {

		private var _message:String;
		private var _type:Number;
		private var _lock:Boolean;
										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>AppMessage</code>.		 */		public function AppMessage() { }						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the message		 */		public function get message():String { return _message; }				/**		 * Gets the message's type.		 */		public function get type():Number { return _type; }				/**		 * Gets if the message should lock the application.		 */		public function get lock():Boolean { return _lock; }				/* ****** *		 * PUBLIC *		 * ****** */		/**		 * @inheritDoc		 */		public function populate(xml:XML, ...optionnals:Array):void {			_message = xml[0];
			_type = parseInt(xml.@type);
			_lock = parseBoolean(xml.@lock);
		}
				/**		 * Populate the value object.		 * 		 * @param message	message to display		 * @param type		type of the message (1:content, 2:error, 3:success)		 * @param lock		lock the application or not		 */		public function dynamicPopulate(message:String, type:int, lock:Boolean = false):void {			_message = message;
			_type = type;
			_lock = lock;		}						/* ******* *		 * PRIVATE *		 * ******* */			}}