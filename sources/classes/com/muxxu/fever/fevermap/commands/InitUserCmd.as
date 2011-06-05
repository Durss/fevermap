package com.muxxu.fever.fevermap.commands {
	import flash.net.URLVariables;
	import com.nurun.structure.environnement.configuration.Config;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import com.nurun.core.commands.Command;
	import com.nurun.core.commands.AbstractCommand;
	import com.nurun.core.commands.events.CommandEvent;

	import flash.events.Event;
	
	/**
	 * The  InitUserCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to initialise the user's data.
	 *
	 * @author Francois
	 * @date 10 mars 2011;
	 */
	public class InitUserCmd extends AbstractCommand implements Command {

		private var _loader:URLLoader;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  InitUserCmd() {
			super();
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Execute the concrete InitUserCmd command.
		 * Must dispatch the CommandEvent.COMPLETE event when done.
		 */
		public override function execute():void {
			var req:URLRequest = new URLRequest(Config.getVariable("initUser"));
			var data:URLVariables = new URLVariables();
			req.data = data;
			_loader.load(req);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		private function loadCompleteHandler(event:Event):void {
			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
		}

		private function loadErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new CommandEvent(CommandEvent.ERROR, "Unable to initialise user"));
		}
	}
}
