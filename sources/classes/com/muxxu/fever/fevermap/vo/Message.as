package com.muxxu.fever.fevermap.vo {
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.core.lang.vo.XMLValueObject;
	
	/**
	 * 
	 * @author Francois
	 * @date 26 janv. 2011;
	 */
	public class Message implements XMLValueObject {

		private var _id:Number;
		private var _uid:Number;
		private var _pseudo:String;
		private var _locked:Boolean;
		private var _date:Date;
		private var _message:String;
		private var _love:Number;
		private var _reports:Number;
		private var _reporters:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Message</code>.
		 */
		public function Message() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the message's ID
		 */
		public function get id():Number { return _id; }
		
		/**
		 * Gets the author's ID
		 */
		public function get uid():Number { return _uid; }
		
		/**
		 * Gets the author's name
		 */
		public function get pseudo():String { return _pseudo; }
		
		/**
		 * Gets if the author has been locked
		 */
		public function get locked():Boolean { return _locked; }
		
		/**
		 * Gets the post date
		 */
		public function get date():Date { return _date; }
		
		/**
		 * Gets the message
		 */
		public function get message():String { return _message; }
		
		/**
		 * Gets the love amount
		 */
		public function get love():int { return _love; }
		
		/**
		 * Gets the number of reports
		 */
		public function get reports():Number { return _reports; }
		
		/**
		 * Gets the reporters
		 */
		public function get reporters():String { return _reporters; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(xml:XML, ...optionnals:Array):void {
			_id = parseInt(xml.@id);
			_reports = parseInt(xml.@reports);
			_reporters = ","+xml.@reporters;
			_uid = parseInt(xml.@uid);
			_love = parseInt(xml.@love);
			_pseudo = xml.@pseudo;
			_locked = parseBoolean(xml.@lock);
			_date = new Date(parseInt(xml.@date) * 1000);
			_message = xml[0];
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}