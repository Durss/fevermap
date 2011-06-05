package com.muxxu.fever.fevermap.crypto {
	import flash.net.URLVariables;

	/**
	 * Provides methods to encrypt and decrypt requests.
	 * 
	 * @author Francois
	 */
	public class RequestEncrypter {
		
		private static const _KEY:String = "fc82";		private static const _DIGITS:int = 6;
		
		/**
		 * Encrypts an <code>URLVariables</code> data.
		 * 
		 * @param vars	variables to encrypt.
		 * 
		 * @return an <code>URLVariables</code> instance with encrypted data.
		 */
		public static function encrypt(vars:URLVariables, varsStr:String = null):URLVariables {
			var i:int, len:int, str:String, tmp:String, res:URLVariables;//, key:String;
			str = "";
			res = new URLVariables();
			if(varsStr == null) {
//				for (key in vars) {
//					key = key.replace(/\&/gi, "#*CrYptESP*#");//					key = key.replace(/\=/gi, "#*CrYptEQU*#");
//					vars[key] = vars[key].replace(/\&/gi, "#*CrYptESP*#");//					vars[key] = vars[key].replace(/\=/gi, "#*CrYptEQU*#");
//					str += "&" + key + "=" + vars[key];
//				}
				str = "&"+vars.toString();
			}else{
				str = varsStr;
			}
			tmp = "";
			len = str.length;
			for(i = 0; i < len; ++i) {
				tmp += toDigits(str.charCodeAt(i), _DIGITS);
			}
			str = tmp;
			
			len = _KEY.length;
			for(i = 0; i < len; ++i) {
				switch(_KEY.charAt(i)) {
					case "0": str = sl(str, 2); break;
					case "1": str = sr(str, 12); break;
					case "2": str = pl(str, 5); break;
					case "3": str = sl(str, 6); break;
					case "4": str = pr(str, 15); break;
					case "5": str = sr(str, 9); break;
					case "6": str = sr(str, 6); break;
					case "7": str = pr(str, 3); break;
					case "8": str = pl(str, 2); break;
					case "9": str = pl(str, 8); break;
					case "a": str = sr(str, 6); break;
					case "b": str = pr(str, 12); break;
					case "c": str = sr(str, 11); break;
					case "d": str = sl(str, 4); break;
					case "e": str = pl(str, 1); break;
					default:
					case "f": str = sl(str, 10); break;
				}
			}
			res.data = str;
			return res;
		}
		
		/**
		 * Encrypts an <code>URLVariables</code> data.
		 * 
		 * @param vars	variables to encrypt.
		 * 
		 * @return an <code>URLVariables</code> instance with encrypted data.
		 */
		public static function encryptServer(data:XML):XML {
			var i:int, len:int, str:String, tmp:String;
			str = data.toXMLString();
			tmp = "";
			len = str.length;
			for(i = 0; i < len; ++i) {
				tmp += toDigits(str.charCodeAt(i), _DIGITS);
			}
			str = tmp;
			
			len = _KEY.length;
			for(i = 0; i < len; ++i) {
				switch(_KEY.charAt(i)) {
					case "0": str = sl(str, 2); break;
					case "1": str = sr(str, 12); break;
					case "2": str = pl(str, 5); break;
					case "3": str = sl(str, 6); break;
					case "4": str = pr(str, 15); break;
					case "5": str = sr(str, 9); break;
					case "6": str = sr(str, 6); break;
					case "7": str = pr(str, 3); break;
					case "8": str = pl(str, 2); break;
					case "9": str = pl(str, 8); break;
					case "a": str = sr(str, 6); break;
					case "b": str = pr(str, 12); break;
					case "c": str = sr(str, 11); break;
					case "d": str = sl(str, 4); break;
					case "e": str = pl(str, 1); break;
					default:
					case "f": str = sl(str, 10); break;
				}
			}
			
			return new XML("<root>" + str + "</root>");
		}
		
		/**
		 * Decrypts an <code>XML</code> data.
		 * 
		 * @param xml	XML source to decrypt.
		 * 
		 * @return an <code>XML</code> instance with decrypted data.
		 */
		public static function decryptServer(data:String):URLVariables {
			var i:int, len:int, vars:Array, str:String, tmp:String, res:URLVariables;
			
			str = data;
			len = _KEY.length;
			for(i = len-1; i > -1; --i) {
				switch(_KEY.charAt(i)) {
					case "0": str = sr(str, 2); break;
					case "1": str = sl(str, 12); break;
					case "2": str = pr(str, 5); break;
					case "3": str = sr(str, 6); break;
					case "4": str = pl(str, 15); break;
					case "5": str = sl(str, 9); break;
					case "6": str = sl(str, 6); break;
					case "7": str = pl(str, 3); break;
					case "8": str = pr(str, 2); break;
					case "9": str = pr(str, 8); break;
					case "a": str = sl(str, 6); break;
					case "b": str = pl(str, 12); break;
					case "c": str = sl(str, 11); break;
					case "d": str = sr(str, 4); break;
					case "e": str = pr(str, 1); break;
					default:
					case "f": str = sr(str, 10); break;
				}
			}
			
			tmp = "";
			len = str.length;
			for(i = 0; i < len; i+=_DIGITS) {
				tmp += String.fromCharCode(str.substr(i, _DIGITS));
			}
			
			res = new URLVariables();
			vars = tmp.split("&");
			len = vars.length;
			var chunks:Array;
			for(i = 1; i < len; ++i) {
				chunks = vars[i].split("=");
				res[chunks[0]] = chunks[1];
			}
			return res;
		}
		
		/**
		 * Decrypts an <code>XML</code> data.
		 * 
		 * @param xml	XML source to decrypt.
		 * 
		 * @return an <code>XML</code> instance with decrypted data.
		 */
		public static function decrypt(source:String):XML {
			var i:int, len:int, tmp:String;
			
			len = _KEY.length;
			for(i = len-1; i > -1; --i) {
				switch(_KEY.charAt(i)) {
					case "0": source = sr(source, 2); break;
					case "1": source = sl(source, 12); break;
					case "2": source = pr(source, 5); break;
					case "3": source = sr(source, 6); break;
					case "4": source = pl(source, 15); break;
					case "5": source = sl(source, 9); break;
					case "6": source = sl(source, 6); break;
					case "7": source = pl(source, 3); break;
					case "8": source = pr(source, 2); break;
					case "9": source = pr(source, 8); break;
					case "a": source = sl(source, 6); break;
					case "b": source = pl(source, 12); break;
					case "c": source = sl(source, 11); break;
					case "d": source = sr(source, 4); break;
					case "e": source = pr(source, 1); break;
					default:
					case "f": source = sr(source, 10); break;
				}
			}
			
			tmp = "";
			len = source.length;
			for(i = 0; i < len; i+=_DIGITS) {
				tmp += String.fromCharCode(source.substr(i, _DIGITS));
			}
			
			return new XML(tmp);
		}
		
		
		
		/**
		 * Shift to the left X times
		 */
		private static function sl(src:String, v:int):String {
			var i:int, strlen:Number;
			strlen = src.length;
			if(strlen < 2) return src;
			for(i = 0; i < v; ++i) {
				src = src.substr(1, strlen) + src.substr(0, 1);
			}
			return src;
		}
		
		/**
		 * Shift to the right X times
		 */
		private static function sr(src:String, v:int):String {
			var i:int, strlen:Number;
			strlen = src.length;
			if(strlen < 2) return src;
			for(i = 0; i < v; ++i) {
				src = src.substr(strlen-1, 1) + src.substr(0, strlen-1);
			}
			return src;
		}
		
		/**
		 * Permutes each X numbers from left
		 */
		private static function pl(src:String, v:int):String {
			var i:int, strlen:Number, chars:Array, tmp:String;
			strlen = src.length - v;
			chars = src.split("");
			if(strlen < 2) return src;
			for(i = 0; i < strlen; i+=v) {
				tmp = chars[i];
				chars[i] = chars[i+v];
				chars[i+v] = tmp;
			}
			return chars.join("");
		}
		
		/**
		 * Permutes each X numbers from right
		 */
		private static function pr(src:String, v:int):String {
			var i:int, strlen:Number, chars:Array, tmp:String;
			strlen = Math.floor((src.length-1)/v)*v;
			chars = src.split("");
			if(strlen < 2) return src;
			for(i = strlen; i > 0; i-=v) {
				tmp = chars[i-v];
				chars[i-v] = chars[i];
				chars[i] = tmp;
			}
			return chars.join("");
		}
		
		/**
		 * Complete a number to have it on X digits.
		 * 
		 * @param src		source to complete.
		 * @param digits	digits minimum to have
		 * 
		 * @return the number on X digits
		 */
		private static function toDigits(src:int, digits:int = 4):String {
			var res:String = src.toString();
			while(res.length < digits) res = "0" + res;
			return res;
		}
		
	}
}
