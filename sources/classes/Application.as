package {
	import gs.TweenLite;
	import gs.plugins.ColorMatrixFilterPlugin;
	import gs.plugins.RemoveChildPlugin;
	import gs.plugins.TweenPlugin;

	import net.hires.debug.Stats;

	import com.muxxu.fever.fevermap.commands.AutoLogCmd;
	import com.muxxu.fever.fevermap.commands.InitLibCmd;
	import com.muxxu.fever.fevermap.components.ExceptionView;
	import com.muxxu.fever.fevermap.components.FeedbackButton;
	import com.muxxu.fever.fevermap.components.LockedStateView;
	import com.muxxu.fever.fevermap.components.PoustyView;
	import com.muxxu.fever.fevermap.components.SaveCountdownView;
	import com.muxxu.fever.fevermap.components.ThanksInsert;
	import com.muxxu.fever.fevermap.components.form.FeverCombobox;
	import com.muxxu.fever.fevermap.components.form.LoginForm;
	import com.muxxu.fever.fevermap.components.init.InitConfigurationView;
	import com.muxxu.fever.fevermap.components.map.MapEngineEvent;
	import com.muxxu.fever.fevermap.components.map.MapView;
	import com.muxxu.fever.fevermap.components.menu.MainMenu;
	import com.muxxu.fever.fevermap.components.tooltip.ToolTip;
	import com.muxxu.fever.fevermap.components.tooltip.content.TTTextContent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.ToolTipMessage;
	import com.muxxu.fever.graphics.FocusRectGraphic;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.nurun.components.button.AbstractNurunButton;
	import com.nurun.components.button.focus.NurunButtonKeyFocusManager;
	import com.nurun.components.form.Input;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.commands.SequentialCommand;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import org.libspark.ui.SWFWheel;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	/**	 * Bootstrap class of the application.	 * Must be set as the main class for the flex sdk compiler	 * but actually the real bootstrap class will be the factoryClass	 * designated in the metadata instruction.	 * 	 * @author Francois	 * @date 5 nov. 2010;	 */	 	[SWF(width="1100", height="650", backgroundColor="0xFFFFFF", frameRate="31")]	[Frame(factoryClass="ApplicationLoader")]
	public class Application extends MovieClip {
		
		private var _map:MapView;
		private var _sequenceDetector:KeyboardSequenceDetector;
		private var _tooltip:ToolTip;
		private var _content:TTTextContent;
		private var _timerHide:Timer;
		private var _feedback:FeedbackButton;
		private var _loginForm:LoginForm;
		private var _menu:MainMenu;
		private var _thanksBt:ThanksInsert;
		private var _stats:Stats;
		private var _spin:SpinGraphic;
		private var _configurator:InitConfigurationView;
		private var _exceptionView:DisplayObject;
		private var _libInitialized:Boolean;
		private var _countdown:SaveCountdownView;
		private var _needUpdate:Boolean;
										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>Application</code>.<br>		 */		public function Application() {
			TweenPlugin.activate([ColorMatrixFilterPlugin, RemoveChildPlugin]);			//Sets the local/online mode.			if(SharedObjectManager.getInstance().localMode) {				Config.addPath("server", Config.getUncomputedPath("serverOffline"));			}else{				Config.addPath("server", Config.getUncomputedPath("serverOnline"));			}						addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_tooltip	= addChild(new ToolTip()) as ToolTip;
			_content	= new TTTextContent(false);
			_timerHide	= new Timer(3000, 1);
			DataManager.getInstance().addEventListener(DataManagerEvent.NEED_APP_UPDATE, needUpdateHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.SHOW_APP_MESSAGE, showAppMessageHandler);
			
		}				/**		 * Called when the stage is available.		 */		private function addedToStageHandler(event:Event):void {			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			stage.addEventListener(Event.RESIZE, computePositionsInit);
			SWFWheel.initialize(stage);
			resetApplication();
		}
		
		/**
		 * Setups/Resets the application
		 */
		private function resetApplication(autoLog:Boolean = true):void {
			_spin = addChild(new SpinGraphic()) as SpinGraphic;
			_stats = new Stats();
			//try catch block due to a weird thing with AIR 2.5.1 that doesn't likes UncaughtErroEvent class... yeehaa..
			try {
				_exceptionView = addChild(new ExceptionView());
			}catch(error:Error) {
				_exceptionView = new Sprite();
			}
			
			DataManager.getInstance().muxxuContext = stage.loaderInfo.parameters["pubkey"] != undefined;
			var spool:SequentialCommand = new SequentialCommand();
			spool.haltOnFail = true;
			if(!_libInitialized) {
				_libInitialized = true;
				spool.addCommand(new InitLibCmd());
			}
			if(autoLog) {
				spool.addCommand(new AutoLogCmd(stage.loaderInfo.parameters));
			}
			spool.addEventListener(CommandEvent.COMPLETE, initialize);
			spool.addEventListener(CommandEvent.ERROR, initErrorHandler);
			spool.execute();
			
			_sequenceDetector = new KeyboardSequenceDetector(stage);
			_sequenceDetector.addEventListener(KeyboardSequenceEvent.SEQUENCE, keyboardSequenceHandler);
			_sequenceDetector.addSequence("local", [27,76,79,67,65,76,13]);// escape LOCAL + Enter
			_sequenceDetector.addSequence("stats", KeyboardSequenceDetector.STATS_CODE);// escape STATS + Enter
			
			computePositionsInit();
		}
				/**		 * Resize and replace the elements.		 */		private function computePositionsInit(event:Event = null):void {
			if(_spin == null || stage == null) return;
						PosUtils.centerInStage(_spin);			_spin.x += _spin.width * .5;			_spin.y += _spin.height * .5;		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */
		/**		 * Initializes the class.		 */		private function initialize(event:Event):void {
			_spin.visible = false;
			//Dispose login form if exists
			if(_loginForm != null) {
				_loginForm.dispose();
				removeChild(_loginForm);
				_loginForm = null;
			}
			
			//Dispose the configurator if exists
			if(_configurator != null){
				_configurator.dispose();
				removeChild(_configurator);
				_configurator.removeEventListener(Event.COMPLETE, initialize);
				_configurator = null;
			}
			
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGIN_COMPLETE, initialize);
			
			if(!DataManager.getInstance().isLogged) {
				_loginForm	= addChild(new LoginForm()) as LoginForm;
				DataManager.getInstance().addEventListener(DataManagerEvent.LOGIN_COMPLETE, initialize);
			} else if(SharedObjectManager.getInstance().firstVisit) {
				_configurator = addChild(new InitConfigurationView()) as InitConfigurationView;
				_configurator.addEventListener(Event.COMPLETE, initialize);
			}else{
				_spin.visible = true;
				startApplication();
			}
			addChild(_exceptionView);
		}
		
		/**
		 * Starts the application
		 */
		private function startApplication():void {
			if(_spin != null && contains(_spin)) {
				removeChild(_spin);
				_spin = null;
			}
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.removeEventListener(Event.RESIZE, computePositionsInit);
			
			_map		= addChild(new MapView()) as MapView;
			_menu		= addChild(new MainMenu(_map)) as MainMenu;
			_feedback	= addChild(new FeedbackButton()) as FeedbackButton;
			_thanksBt	= addChild(new ThanksInsert()) as ThanksInsert;
			addChild(_tooltip);
			addChild(new LockedStateView());
			_countdown	= addChild(new SaveCountdownView()) as SaveCountdownView;
			addChild(new PoustyView());
			addChild(_exceptionView);
			
			var pos:Point, zoom:int;
			if(!isNaN(Config.getNumVariable("zoom"))) {
				zoom = MathUtils.restrict(Config.getNumVariable("zoom"), 1, 5);
			}else{
				zoom = _map.zoomLevel;
			}
			if(!isNaN(Config.getNumVariable("x")) && !isNaN(Config.getNumVariable("y"))) {
				pos = new Point(Config.getNumVariable("x"), Config.getNumVariable("y"));
			}else{
				pos = SharedObjectManager.getInstance().playerPosition;
			}
			_map.init(zoom, pos);
			
			computePositions();
			_map.enable();
			
			stage.addEventListener(Event.RESIZE, computePositions);
			
			_timerHide.addEventListener(TimerEvent.TIMER_COMPLETE, _tooltip.close);
			_map.addEventListener(MapEngineEvent.DATA_NEEDED, mapDataNeededHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_AREA_COMPLETE, loadAreaCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_AREA_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_AREA_COMPLETE, addAreaCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_AREA_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.UPDATE_MAP, updateMapHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.OPEN_ZONE, openZoneHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.UPDATE_POS_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_MESSAGE_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_MESSAGE_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.REPORT_MESSAGE_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.GET_USERS_ON_ERROR, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.PATH_FINDER_NO_PATH_FOUND, errorHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOGOUT_COMPLETE, logOutCompleteHandler);
			
			var types:Array = [AbstractNurunButton, Input, FeverCombobox];
			NurunButtonKeyFocusManager.getInstance().initialize(stage, new FocusRectGraphic(),types);
			addChild(NurunButtonKeyFocusManager.getInstance());
			stage.stageFocusRect = false;
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusChangeHandler);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeHandler);
		}
		
		/**
		 * Forces the focus to an InteractiveObject to be sure that CTRL+C/V works.
		 */
		private function focusChangeHandler(event:FocusEvent):void {
			if(!(stage.focus is InteractiveObject)) {
				stage.focus = _map;
			}
		}
		
//		private function clickHandler(event:MouseEvent):void {
//			DataManager.getInstance().findPath(new Point(0,0), new Point(31,-24));
////			var i:int, len:int;
////			len = DataManager.getInstance().pfMap.length;
////			var txt:String = "var map:Array = [];\r";
////			for(i = 0; i < len; ++i) {
////				txt += "map["+i+"] = ["+DataManager.getInstance().pfMap[i]+"];\r";
////			}
//			return;
//			var map:Array = DataManager.getInstance().pfMap;
//			var bmd:BitmapData = new BitmapData(map.length, map[0].length, true,0);
//			var inc:int;
//			var lenI:int = map.length;
//			var lenJ:int = map[0].length;
//			for(var i:int = 0; i<lenI; i++) {
//				for(var j:int = 0; j<lenJ; j++) {
//					inc++;
//					bmd.setPixel32(j, i, map[i][j]==0? 0x880000ff : 0xffff0000);
//				}
//			}
//			var fs:FileStream = new FileStream();
//			fs.open(new File(File.desktopDirectory.nativePath+"/image.png"), FileMode.WRITE);
//			fs.writeBytes(PNGEncoder.encode(bmd));
//		}
		
		/**
		 * Called when user logs out successfully.
		 */
		private function logOutCompleteHandler(event:DataManagerEvent):void {
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.removeEventListener(Event.RESIZE, computePositionsInit);
			
			_sequenceDetector.removeEventListener(KeyboardSequenceEvent.SEQUENCE, keyboardSequenceHandler);
			_sequenceDetector.dispose();
			
			_timerHide.removeEventListener(TimerEvent.TIMER_COMPLETE, _tooltip.close);
			_map.removeEventListener(MapEngineEvent.DATA_NEEDED, mapDataNeededHandler);
			
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOAD_AREA_COMPLETE, loadAreaCompleteHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOAD_AREA_ERROR, errorHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.ADD_AREA_COMPLETE, addAreaCompleteHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.ADD_AREA_ERROR, errorHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.UPDATE_MAP, updateMapHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.NEED_APP_UPDATE, needUpdateHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.SHOW_APP_MESSAGE, showAppMessageHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.UPDATE_POS_ERROR, errorHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOAD_MESSAGE_ERROR, errorHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.ADD_MESSAGE_ERROR, errorHandler);
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOGOUT_COMPLETE, logOutCompleteHandler);
			
			_map = null;
			_sequenceDetector = null;
			_feedback = null;
			_loginForm = null;
			_menu = null;
			_thanksBt = null;
			_stats = null;
			_spin = null;
			_configurator = null;
			_exceptionView = null;
			
			resetApplication(false);
		}
		
		/**		 * Resize and replace the elements.		 */		private function computePositions(event:Event = null):void {
			_map.width = Math.min(4000, stage.stageWidth);			_map.height = Math.min(4000, stage.stageHeight);
			PosUtils.centerInStage(_map);
						_feedback.validate();			PosUtils.centerInStage(_feedback);
			_feedback.y = Math.round(stage.stageHeight - _feedback.height + 2);
			_feedback.x = Math.min(_feedback.x, stage.stageWidth - _thanksBt.width - _feedback.width - 10);
			
			_thanksBt.x = stage.stageWidth - _thanksBt.width;
			_thanksBt.y = stage.stageHeight - _thanksBt.height;
			
			_stats.x = stage.stageWidth - 70;
			
			PosUtils.hCenterIn(_countdown, stage);
			PosUtils.alignToBottomOf(_countdown, stage, 40);
		}
		
		/**
		 * Called if initialization fails
		 */
		private function initErrorHandler(event:CommandEvent):void {
			if(_needUpdate) return;
			
			var tf:CssTextField = addChild(new CssTextField("error")) as CssTextField;
			tf.background = true;
			tf.backgroundColor = 0;
			tf.text = Label.getLabel("initFaillure")+"<br /><br /><b>"+event.data+"</b>";
			PosUtils.centerInStage(tf);
		}				/**		 * Called when map needs data.		 */		private function mapDataNeededHandler(event:MapEngineEvent):void {
			_map.disable();
			DataManager.getInstance().loadArea(event.dataRect, _map.zoomLevel == 5);		}		/**		 * Called when the model asks for the map to render.		 */
		private function updateMapHandler(event:DataManagerEvent):void {
			_map.update(true);
		}		
		/**
		 * Called when the model asks for a zone opening.
		 */
		private function openZoneHandler(event:DataManagerEvent):void {
			_menu.close();
			_map.openZone(new Point(event.area.x, event.area.y));
		}		/**		 * Called when a catchable keyboard sequence is written.		 */		private function keyboardSequenceHandler(e:KeyboardSequenceEvent):void {			//Switch between offline and online mode			if(e.sequenceId == "local") {				var local:Boolean = !SharedObjectManager.getInstance().localMode;				SharedObjectManager.getInstance().localMode = local;				if(local) {					Config.addPath("server", Config.getUncomputedPath("serverOffline"));					TweenLite.to(this, .1, {colorMatrixFilter:{brightness:-.5, remove:true}});				}else{					Config.addPath("server", Config.getUncomputedPath("serverOnline"));					TweenLite.to(this, .1, {colorMatrixFilter:{brightness:2.5, remove:true}});				}				if(_map!= null) _map.update();			}else if(e.sequenceId == "stats"){
				if(contains(_stats)){
					removeChild(_stats);				}else{
					addChild(_stats);
				}
			}
			TweenLite.to(this, .25, {colorMatrixFilter:{brightness:1, remove:true}, delay:.1, overwrite:0});
		}
		
										// __________________________________________________________ SERVER RESULTS		/**		 * Called when an area loading completes.		 */		private function loadAreaCompleteHandler(event:DataManagerEvent):void {			_map.enable();			_map.populate(event.items, event.area);		}

		/**		 * Called when an area submition completes.		 */		private function addAreaCompleteHandler(event:DataManagerEvent):void {			_map.enable();			_map.populate(event.items, event.area);		}
		
		/**
		 * Called when an error occurs
		 */
		private function errorHandler(event:DataManagerEvent):void {
			var errorMsg:String = "";
			switch(event.type){
				case DataManagerEvent.LOAD_AREA_ERROR: errorMsg = "loadAreaError" + event.resultCode; break;
				case DataManagerEvent.ADD_AREA_ERROR: errorMsg = "addAreaError" + event.resultCode; break;
				case DataManagerEvent.LOAD_MESSAGE_ERROR: errorMsg = "loadMessageError" + event.resultCode; break;
				case DataManagerEvent.ADD_MESSAGE_ERROR: errorMsg = "addMessageError" + event.resultCode; break;
				case DataManagerEvent.UPDATE_POS_ERROR: errorMsg = "positionUpdateError" + event.resultCode; break;
				case DataManagerEvent.DATA_DOWNLOAD_ERROR: errorMsg = "dataDownloadError" + event.resultCode; break;
				case DataManagerEvent.DATA_UPLOAD_ERROR: errorMsg = "dataUploadError" + event.resultCode; break;
				case DataManagerEvent.GET_USERS_ON_ERROR: errorMsg = "getUsersOnError" + event.resultCode; break;
				case DataManagerEvent.REPORT_MESSAGE_ERROR: errorMsg = "reportMessageError" + event.resultCode; break;
				case DataManagerEvent.PATH_FINDER_NO_PATH_FOUND: errorMsg = "menuSearchPathNoResult"; break;
			}
			if(_map != null) _map.enable();
			_content.populate(Label.getLabel(errorMsg), "tooltipContentError");
			_tooltip.open(new ToolTipMessage(_content));
			_timerHide.reset();
			_timerHide.start();
			PosUtils.centerInStage(_tooltip);
		}		/**		 * Called if the application needs to be updated		 */		private function needUpdateHandler(event:DataManagerEvent):void {
			if(Capabilities.playerType.toLowerCase() == "desktop") {				_content.populate(Label.getLabel("needUpdateAir"), "tooltipContentError");				_tooltip.open(new ToolTipMessage(_content));				PosUtils.centerInStage(_tooltip);				
				_timerHide.stop();
				if(_map != null) _map.disable();
			}else{				_content.populate(Label.getLabel("needUpdateSwf"), "tooltipContentError");				_tooltip.open(new ToolTipMessage(_content));				PosUtils.centerInStage(_tooltip);				if(ExternalInterface.available) {					ExternalInterface.call("reload");				}			}
			_needUpdate = true;
			removeChild(_spin);		}				/**		 * Displays a message from the server.		 */		private function showAppMessageHandler(event:DataManagerEvent):void {			var style:String;			if(event.message.type == 1) style = "tooltipContent";			if(event.message.type == 2) style = "tooltipContentError";			if(event.message.type == 3) style = "tooltipContentSuccess";			_content.populate(event.message.message, style);
			_tooltip.open(new ToolTipMessage(_content));
			if(event.message.lock) {				_timerHide.stop();				if(_map != null) _map.disable();			}else{				_timerHide.reset();				_timerHide.start();			}			PosUtils.centerInStage(_tooltip);		}
			}}