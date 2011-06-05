package com.muxxu.fever.fevermap.commands {	import com.muxxu.fever.fevermap.data.DataManager;	import com.muxxu.fever.fevermap.data.SharedObjectManager;	import com.muxxu.fever.fevermap.events.DataManagerEvent;	import com.nurun.core.commands.Command;	import com.nurun.core.commands.events.CommandEvent;	import com.nurun.structure.environnement.label.Label;	import flash.events.EventDispatcher;	import flash.system.Capabilities;		/**	 * The  CheckLogStateCmd is a concrete implementation of the ICommand interface.	 * Its responsability is to check if the user is loHTTPPath.getPath("login")ncois	 * @date 11 nov. 2010;	 */	public class AutoLogCmd extends EventDispatcher implements Command {				private var _flashvars:Object;						

		/* *********** *		 * CONSTRUCTOR *		 * *********** */
		public function AutoLogCmd(flashvars:Object) {
			_flashvars = flashvars;		}
						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */		/**		 * @inheritDoc		 */		public function execute():void {			if( (SharedObjectManager.getInstance().uid.length > 0 && SharedObjectManager.getInstance().pubkey.length > 0)				|| (_flashvars["uid"] != undefined && _flashvars["pubkey"] != undefined) ) {				DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_COMPLETE, loginCompleteHandler);				DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_ERROR, loginErrorHandler);
				DataManager.getInstance().addEventListener(DataManagerEvent.NEED_APP_UPDATE, loginErrorHandler);				DataManager.getInstance().addEventListener(DataManagerEvent.SHOW_APP_MESSAGE, loginErrorHandler);				if(_flashvars["uid"] != undefined) {
					DataManager.getInstance().logIn(_flashvars["uid"], _flashvars["pubkey"]);
				}else{
					DataManager.getInstance().logIn(SharedObjectManager.getInstance().uid, SharedObjectManager.getInstance().pubkey);
				}			}else{
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}		}
		
		/**
		 * @inheritDoc
		 */
		public function halt():void {
			//Don't care...
		}						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Called when login completes.		 */		private function loginCompleteHandler(event:DataManagerEvent):void {
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_COMPLETE, loginCompleteHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_ERROR, loginErrorHandler);			dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));		}				/**		 * Called if login fails.		 */
		private function loginErrorHandler(event:DataManagerEvent):void {			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_COMPLETE, loginCompleteHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_ERROR, loginErrorHandler);
			var message:String;
			if(event.type == DataManagerEvent.SHOW_APP_MESSAGE) {
				 message = event.message.message; 
			} else if(event.type == DataManagerEvent.NEED_APP_UPDATE) {				if(Capabilities.playerType.toLowerCase() == "desktop") {					message = Label.getLabel("needUpdateAir");				}else{					message = Label.getLabel("needUpdateSwf"); 
				}			}else{				message = "Unknown login faillure";			}			dispatchEvent(new CommandEvent(CommandEvent.ERROR, message));
		}
	}}