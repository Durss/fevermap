package com.muxxu.fever.fevermap.crypto {
	import flash.utils.ByteArray;
	import com.nurun.utils.crypto.XOR;
	
	/**
	 * Applies an XOR encryption to a ByteArray with a static encryption key.
	 * @author Francois
	 */
	public function FXOR(data:ByteArray):void {
		XOR(data, "hyudsds8fd7SD2398w");
	}
}
