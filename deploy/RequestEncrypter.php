<?php
class RequestEncrypter {

	private static $_KEY = "fc82";
	private static $_DIGITS = 6;
	
	public static function encrypt($str) {
			$tmp = "";
			$len = strlen($str);
			for($i = 0; $i < $len; $i++) {
				$tmp .= self::toDigits(ord($str[$i]), self::$_DIGITS);
			}
			$str = $tmp;
			
			$len = strlen(self::$_KEY);
			for($i = 0; $i < $len; $i++) {
				switch(self::$_KEY[$i]) {
					case "0": $str = self::sl($str, 2); break;
					case "1": $str = self::sr($str, 12); break;
					case "2": $str = self::pl($str, 5); break;
					case "3": $str = self::sl($str, 6); break;
					case "4": $str = self::pr($str, 15); break;
					case "5": $str = self::sr($str, 9); break;
					case "6": $str = self::sr($str, 6); break;
					case "7": $str = self::pr($str, 3); break;
					case "8": $str = self::pl($str, 2); break;
					case "9": $str = self::pl($str, 8); break;
					case "a": $str = self::sr($str, 6); break;
					case "b": $str = self::pr($str, 12); break;
					case "c": $str = self::sr($str, 11); break;
					case "d": $str = self::sl($str, 4); break;
					case "e": $str = self::pl($str, 1); break;
					default:
					case "f": $str = self::sl($str, 10); break;
				}
			}
			return $str;
	}
	
	public static function decrypt($str) {
		//$str = urldecode($str);
		$len = strlen(self::$_KEY);
		for($i = $len-1; $i > -1; $i--) {
			switch(self::$_KEY[$i]) {
				case "0": $str = self::sr($str, 2); break;
				case "1": $str = self::sl($str, 12); break;
				case "2": $str = self::pr($str, 5); break;
				case "3": $str = self::sr($str, 6); break;
				case "4": $str = self::pl($str, 15); break;
				case "5": $str = self::sl($str, 9); break;
				case "6": $str = self::sl($str, 6); break;
				case "7": $str = self::pl($str, 3); break;
				case "8": $str = self::pr($str, 2); break;
				case "9": $str = self::pr($str, 8); break;
				case "a": $str = self::sl($str, 6); break;
				case "b": $str = self::pl($str, 12); break;
				case "c": $str = self::sl($str, 11); break;
				case "d": $str = self::sr($str, 4); break;
				case "e": $str = self::pr($str, 1); break;
				default:
				case "f": $str = self::sr($str, 10); break;
			}
		}
		
		$tmp = "";
		$len = strlen($str);
		for($i = 0; $i < $len; $i += self::$_DIGITS) {
			$tmp .= chr(substr($str, $i, self::$_DIGITS));
		}
		
		$vars = explode("&", $tmp);
		$len = count($vars);
		$chunks = array();
		$res = array();
		for($i = 1; $i < $len; $i++) {
			$chunks = explode("=", $vars[$i]);
			/*
			$chunks[0] = str_replace("#*CrYptESP*#", "&", $chunks[0]);
			$chunks[0] = str_replace("#*CrYptEQU*#", "=", $chunks[0]);
			$chunks[1] = str_replace("#*CrYptESP*#", "&", $chunks[1]);
			$chunks[1] = str_replace("#*CrYptEQU*#", "=", $chunks[1]);
			*/
			$res[$chunks[0]] = urldecode($chunks[1]);
		}
		return $res;
	}
		
		
		
	/**
	 * Shift to the left X times
	 */
	private static function sl($src, $v) {
		$strlen = strlen($src);
		if($strlen < 2) return $src;
		for($i = 0; $i < $v; $i++) {
			$src = substr($src, 1, $strlen) . substr($src, 0, 1);
		}
		return $src;
	}
	
	/**
	 * Shift to the right X times
	 */
	private static function sr($src, $v) {
		$strlen = strlen($src);
		if($strlen < 2) return $src;
		for($i = 0; $i < $v; $i++) {
			$src = substr($src, $strlen-1, 1) . substr($src, 0, $strlen-1);
		}
		return $src;
	}
	
	/**
	 * Permutes each X numbers from left
	 */
	private static function pl($src, $v) {
		$strlen = strlen($src) - $v;
		if($strlen < 2) return $src;
		for($i = 0; $i < $strlen; $i += $v) {
			$tmp = $src[$i];
			$src[$i] = $src[$i + $v];
			$src[$i + $v] = $tmp;
		}
		return $src;
	}
	
	/**
	 * Permutes each X numbers from right
	 */
	private static function pr($src, $v) {
		$strlen = floor((strlen($src) - 1) / $v) * $v;
		if($strlen < 2) return $src;
		for($i = $strlen; $i > 0; $i -= $v) {
			$tmp = $src[$i - $v];
			$src[$i - $v] = $src[$i];
			$src[$i] = $tmp;
		}
		return $src;
	}
	
	/**
	 * Complete a number to have it on X digits.
	 * 
	 * @param src		source to complete.
	 * @param digits	digits minimum to have
	 * 
	 * @return the number on X digits
	 */
	private static function toDigits($src, $digits = 4) {
		while (strlen($src) < $digits) $src = "0" . $src;
		return $src;
	}
	
}
?>