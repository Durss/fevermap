package com.muxxu.fever.fevermap.vo {
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.core.lang.vo.XMLValueObject;
	
	/**
	 * 
	 * @author Francois
	 * @date 20 nov. 2010;
	 */
	public class Revision implements XMLValueObject {

		private var _uid:int;
		private var _pseudo:String;
		private var _locked:Boolean;
		private var _directions:String;
		private var _items:String;
		private var _enemies:String;
		private var _date:Date;
		private var _matrix:String;
		private var _x:Number;
		private var _y:Number;
		private var _isNew:Boolean;
		private var _matrixBefore:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Revision</code>.
		 */
		public function Revision() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get x():Number { return _x; }

		public function get y():Number { return _y; }

		public function get uid():int { return _uid; }

		public function get pseudo():String { return _pseudo; }

		public function get locked():Boolean { return _locked; }

		public function get directions():String { return _directions; }

		public function get items():String { return _items; }

		public function get enemies():Array { return _enemies.split(","); }

		public function get date():Date { return _date; }

		public function get matrix():String { return _matrix; }

		public function get isNew():Boolean { return _isNew; }

		public function get matrixBefore():String { return _matrixBefore; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(xml:XML, ...optionnals:Array):void {
			_x = parseInt(xml.@x);
			_y = parseInt(xml.@y);
			_uid = parseInt(xml.@uid);
			_pseudo = xml.@pseudo;
			_locked = parseBoolean(xml.@lock);
			_isNew = parseBoolean(xml.@isNew);
			_directions = xml.@d;
			_items = xml.@i;
			_matrix = xml.@matrix;
			_matrixBefore = xml.@matrixBefore;
			_enemies = xml.@e;
			_date = new Date(parseInt(xml.@date) * 1000);
		}
		
		/**
		 * Gets a string representation of the value object.
		 */
		public function toString():String {
			return "[Revision :: pseudo=\"" + pseudo + "\", date=" + date + "]";
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}