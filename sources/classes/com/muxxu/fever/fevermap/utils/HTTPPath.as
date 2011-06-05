package com.muxxu.fever.fevermap.utils {	import com.nurun.structure.environnement.configuration.Config;	/**	 * Util class to get an HTTP path depending on the local or online app state.	 * 	 * @author  Francois	 */	public class HTTPPath {										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>HTTPPath</code>.		 */		public function HTTPPath() { }						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */		public static function getPath(id:String):String {			return Config.getUncomputedPath(id).replace(/\$\{server\}/gi, Config.getPath("server")).replace(/\{v_SESSID\}/gi, Config.getVariable("SESSID"));		}						/* ******* *		 * PRIVATE *		 * ******* */			}}