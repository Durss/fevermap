package com.muxxu.fever.fevermap.components.tooltip.content {

	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;	/**	 * Displays a simple text content.	 * 	 * @author  Francois	 */	public class TTTextContent extends Sprite implements ToolTipContent, Disposable {		private var _tf:CssTextField;		private var _canBedisposed:Boolean;								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>TTTextContent</code>.		 */		public function TTTextContent(canBedisposed:Boolean = true, text:String = "", css:String = "tooltipContent") {			_canBedisposed = canBedisposed;			initialize();			if(text != null && text.length > 0) {				populate(text, css);			}		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Sets the component's width without simply scaling it.		 */		override public function set width(value:Number):void {			_tf.width = value;			_tf.wordWrap = value > 0;			dispatchEvent(new Event(Event.RESIZE));		}

		/**
		 * @inheritDoc
		 */
		public function get locked():Boolean { return false; }						/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Populates the content		 */		public function populate(text:String, css:String = "tooltipContent", width:int=0):void {			if(width > 0) {				this.width = width;			}			_tf.setText(text, css);			dispatchEvent(new Event(Event.RESIZE));		}				/**		 * Makes the component garbage collectable.		 */		public function dispose():void {			if(_canBedisposed){				_tf.text = "";				removeChild(_tf);				_tf = null;			}		}								/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initializes the class.		 */		private function initialize():void {			_tf = addChild(new CssTextField()) as CssTextField;			_tf.autoSize = TextFieldAutoSize.LEFT;
		}
	}}