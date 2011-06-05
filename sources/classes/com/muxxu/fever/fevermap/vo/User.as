package com.muxxu.fever.fevermap.vo {
	import flash.geom.Point;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.core.lang.vo.XMLValueObject;
	
	/**
	 * 
	 * @author Francois
	 * @date 11 févr. 2011;
	 */
	public class User implements XMLValueObject {

		private var _id:Number;
		private var _locked:Boolean;
		private var _name:String;
		private var _pos:Point;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>User</code>.
		 */
		public function User() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the user's ID
		 */
		public function get id():Number { return _id; }
		
		/**
		 * Gets the user's position
		 */
		public function get pos():Point { return _pos; }
		
		/**
		 * Gets if the user is locked.
		 */
		public function get locked():Boolean { return _locked; }
		
		/**
		 * Gets the user's name.
		 */
		public function get name():String { return _name; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(xml:XML, ...optionnals:Array):void {
			_id = parseInt(xml.@id);
			_pos = new Point(parseInt(xml.@x), parseInt(xml.@y));
			_locked = parseBoolean(xml.@locked);
			_name = xml[0];
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}