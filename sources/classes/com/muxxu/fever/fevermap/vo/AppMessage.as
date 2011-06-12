package com.muxxu.fever.fevermap.vo {
	import com.nurun.core.lang.vo.XMLValueObject;
	public class AppMessage implements XMLValueObject {

		private var _message:String;
		private var _type:Number;
		private var _lock:Boolean;
		
			_type = parseInt(xml.@type);
			_lock = parseBoolean(xml.@lock);
		}
		
			_type = type;
			_lock = lock;