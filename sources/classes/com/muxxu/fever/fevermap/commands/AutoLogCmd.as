package com.muxxu.fever.fevermap.commands {

		/* *********** *
		public function AutoLogCmd(flashvars:Object) {
			_flashvars = flashvars;

				DataManager.getInstance().addEventListener(DataManagerEvent.NEED_APP_UPDATE, loginErrorHandler);
					DataManager.getInstance().logIn(_flashvars["uid"], _flashvars["pubkey"]);
				}else{
					DataManager.getInstance().logIn(SharedObjectManager.getInstance().uid, SharedObjectManager.getInstance().pubkey);
				}
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
			}
		
		/**
		 * @inheritDoc
		 */
		public function halt():void {
			//Don't care...
		}
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_COMPLETE, loginCompleteHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_ERROR, loginErrorHandler);
		private function loginErrorHandler(event:DataManagerEvent):void {
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_ERROR, loginErrorHandler);
			var message:String;
			if(event.type == DataManagerEvent.SHOW_APP_MESSAGE) {
				 message = event.message.message; 
			} else if(event.type == DataManagerEvent.NEED_APP_UPDATE) {
				}
		}
	}