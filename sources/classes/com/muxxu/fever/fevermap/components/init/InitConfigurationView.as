package com.muxxu.fever.fevermap.components.init {

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.FeverRadioButton;
	import com.muxxu.fever.fevermap.components.menu.filters.MenuFilters;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.graphics.BackToolTipGraphic;
	import com.muxxu.fever.graphics.RockGraphic;
	import com.muxxu.fever.graphics.WarningIconGraphic;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	/**
	 * 
	 * @author Francois
	 * @date 29 janv. 2011;
	 */
	public class InitConfigurationView extends Sprite {
		
		private const _WIDTH:int = 400;

		private var _background:BackToolTipGraphic;
		private var _title:CssTextField;
		private var _warning:WarningIconGraphic;
		private var _description:CssTextField;
		private var _acceptRB:FeverRadioButton;
		private var _declineRB:FeverRadioButton;
		private var _group:FormComponentGroup;
		private var _options:MenuFilters;
		private var _submitBt:FeverButton;
		private var _optionsTitle:CssTextField;
		private var _rock:RockGraphic;
		private var _error:CssTextField;
		private var _downloadBt:FeverButton;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>InitConfigurationView</code>.
		 */
		public function InitConfigurationView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			_rock.filters = [];
			_background.filters = [];
			if(_group != null) _group.dispose();
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.removeEventListener(Event.RESIZE, computePositions);
			_submitBt.removeEventListener(MouseEvent.CLICK, clickHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.DATA_UPLOAD_ERROR, dataUploadResultHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.DATA_UPLOAD_COMPLETE, dataUploadResultHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			
			_background = addChild(new BackToolTipGraphic()) as BackToolTipGraphic;
			_rock = addChild(new RockGraphic()) as RockGraphic;
			_title = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_warning = addChild(new WarningIconGraphic()) as WarningIconGraphic;
			_optionsTitle = addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_options = addChild(new MenuFilters(true)) as MenuFilters;
//			if(SharedObjectManager.getInstance().isSomethingFlagged) {
//				_group = new FormComponentGroup();
//				
//				_description = addChild(new CssTextField("initDescription")) as CssTextField;
//				_acceptRB = addChild(new FeverRadioButton(Label.getLabel("initDataAccept"), "initAccept", "initAcceptSelected")) as FeverRadioButton;
//				_declineRB = addChild(new FeverRadioButton(Label.getLabel("initDataDecline"), "initDecline", "initDeclineSelected")) as FeverRadioButton;
//				_downloadBt = addChild(new FeverButton(Label.getLabel("initDownload"), new Bitmap(new DownloadIconGraphic(NaN, NaN)))) as FeverButton;
//				
//				_group.add(_acceptRB);
//				_group.add(_declineRB);
//				
//				_acceptRB.selected = true;
//			}
			_submitBt = addChild(new FeverButton(Label.getLabel("initSubmit"))) as FeverButton;
			_error = addChild(new CssTextField("error")) as CssTextField;
			
			_title.background = true;
			_title.backgroundColor = 0;
			_title.text = "     "+Label.getLabel("initDataTitle");
			_title.width = _WIDTH;
			
			_warning.x = 4;
			_warning.y = 2;
			
			_optionsTitle.text = Label.getLabel("initDataOptionsTitle");
			_optionsTitle.width = _WIDTH - 6;
			_optionsTitle.x = 3;
			_optionsTitle.y = Math.round(_title.height + 10);
			
			_options.x = 30;
			_options.y = Math.round(_optionsTitle.y + _optionsTitle.height + 3);
			
			if(_description != null) {
				_description.x = 3;
				_description.y = Math.round(_options.y + _options.height + 20);
				_description.width = _WIDTH - 6;
				_description.text = Label.getLabel("initDataDescription");
				
				var margin:int = (_WIDTH - _acceptRB.width - _declineRB.width - 15) * .5;
				_acceptRB.x = margin;
				_declineRB.x = _WIDTH - margin - _declineRB.width;
				_acceptRB.y = Math.round(_description.y + _description.height + 5);
				_declineRB.y = _acceptRB.y;
				_downloadBt.y = _acceptRB.y + _acceptRB.height + 10;
				PosUtils.hCenterIn(_downloadBt, _WIDTH);
			}
			
			PosUtils.hCenterIn(_submitBt, _WIDTH);
			
			if(_downloadBt != null) {
				_submitBt.y = _downloadBt.y + _downloadBt.height + 20;
			}else{
				_submitBt.y = _options.y + _options.height + 20;
			}
			
			_background.y = Math.round(_title.height);
			_background.width = _WIDTH;
			_background.height = Math.round(_submitBt.y + _submitBt.height + 10 - _background.y);
			
			_rock.x = _background.width - _rock.width - 1;
			_rock.y = _background.y + _background.height - _rock.height - 1;
			
			_rock.filters = [new DropShadowFilter(5,225,0,.25,5,5,.5,2)];
			filters = [new DropShadowFilter(5,45,0,.5,5,5,.75,2)];
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.DATA_UPLOAD_ERROR, dataUploadResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.DATA_UPLOAD_COMPLETE, dataUploadResultHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			PosUtils.centerIn(this, stage);
		}
		
		/**
		 * Called when submit button is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _submitBt) {
				if(_group != null && _group.selectedItem == _acceptRB) {
					DataManager.getInstance().uploadData();
					_submitBt.enabled = false;
				}else{
					fireComplete();
				}
			}else if(event.target == _downloadBt) {
				DataManager.getInstance().exportFlags();
			}
		}
		
		/**
		 * Called when upload completes or fails
		 */
		private function dataUploadResultHandler(event:DataManagerEvent):void {
			if(event.type == DataManagerEvent.DATA_UPLOAD_ERROR) {
				_error.background = true;
				_error.backgroundColor = 0;
				_error.text = Label.getLabel("dataUploadError" + event.resultCode);
				_error.y = _submitBt.y + _submitBt.height + 5;
				PosUtils.hCenterIn(_error, _WIDTH);
				_background.height += _error.height;
				_rock.y = _background.y + _background.height - _rock.height - 1;
				_submitBt.enabled = true;
				computePositions();
			}else{
				fireComplete();
			}
		}
		
		/**
		 * Called when the configuration completes.
		 */
		private function fireComplete():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}