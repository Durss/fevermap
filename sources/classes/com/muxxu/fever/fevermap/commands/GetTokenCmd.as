package com.muxxu.fever.fevermap.commands {

	import com.muxxu.fever.fevermap.crypto.RequestEncrypter;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.utils.HTTPPath;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.events.CommandEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	/**
	 * The  GetTokenCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to get the token.
	 *
	 * @author Francois
	 * @date 1 févr. 2011;
	 */
	public class GetTokenCmd extends AbstractCommand implements Command {

		private var _loader:URLLoader;
		private var _start:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  GetTokenCmd() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete GetTokenCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			_start = getTimer();
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			_loader.load(new URLRequest(HTTPPath.getPath("getToken")));
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
		/**
		 * Called when token loading completes.
		 */
		private function loadCompleteHandler(event:Event):void {
			try {
				var data:XML = new XML(RequestEncrypter.decrypt(_loader.data));
			}catch(error:Error) {
				dispatchEvent(new CommandEvent(CommandEvent.ERROR, "Unable to parse token result."));
				return;
			}
			DataManager.getInstance().token = parseFloat(data.child("token")[0]) - _start * .001;
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}
		
		/**
		 * Called if token loading fails
		 */
		private function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "Unable to get token."));
		}
	}
}
