package com.muxxu.fever.fevermap.data {
	import be.dauntless.astar.Astar;
	import be.dauntless.astar.AstarEvent;
	import be.dauntless.astar.BasicTile;
	import be.dauntless.astar.Map;
	import be.dauntless.astar.PathRequest;
	import be.dauntless.astar.analyzers.WalkableAnalyzer;

	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.components.map.icons.MapIslandEntry;
	import com.muxxu.fever.fevermap.crypto.RequestEncrypter;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.events.SharedObjectManagerEvent;
	import com.muxxu.fever.fevermap.utils.HTTPPath;
	import com.muxxu.fever.fevermap.vo.AppMessage;
	import com.muxxu.fever.fevermap.vo.Message;
	import com.muxxu.fever.fevermap.vo.RevisionCollection;
	import com.muxxu.fever.fevermap.vo.User;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.object.ObjectUtils;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
		/**	 * Singleton DataManager	 * 	 * @author Francois	 * @date 5 nov. 2010;	 */	public class DataManager extends EventDispatcher {				private static const _MAP_RADIUS:int = 100;
		private static var _instance:DataManager;
		private var _lastArea:Rectangle;
		private var _loaderToAreas:Dictionary;
		private var _items:Vector.<MapEntry>;
		private var _isLogged:Boolean;
		private var _uid:String;
		private var _pubkey:String;
		private var _fr:FileReference;
		private var _objectFilters:Array;
		private var _objectFiltersStr:String;
		private var _newPoustyPos:Point;
		private var _cache:Array;
		private var _timerClean:Timer;
		private var _muxxuContext:Boolean;
		private var _token:Number;
		private var _isAdmin:Boolean;
		private var _pfMap:Array;
		private var _pfMapEmpty:Array;
		private var _currentPath:Array;
		private var _pfStartPoint:Point;
		private var _pfEndPoint:Point;
		private var _objectToSearch:String;
		private var _currentWorld:String;
		private var _locked:Boolean;
								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>DataManager</code>.		 */		public function DataManager(enforcer:SingletonEnforcer) {			if(enforcer == null) {				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");			}			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Singleton instance getter.		 */		public static function getInstance():DataManager {			if(_instance == null)_instance = new  DataManager(new SingletonEnforcer());			return _instance;			}

		/**
		 * Gets if the user is logged.
		 */
		public function get isLogged():Boolean { return _isLogged; }

		/**
		 * Gets if the user is admin.
		 */
		public function get isAdmin():Boolean { return _isAdmin; }

		/**
		 * Gets the filters.
		 */
		public function get objectFilters():Array { return _objectFilters; }
		
		/**
		 * Gets the filter as a concatenated string
		 */
		public function get objectFiltersStr():String { return _objectFiltersStr; }
		
		/**
		 * Gets if the application is executed inside the muxxu context or not.
		 */
		public function get muxxuContext():Boolean { return _muxxuContext; }

		/**
		 * Sets if the application is executed inside the muxxu context or not.
		 */
		public function set muxxuContext(muxxuContext:Boolean):void { _muxxuContext = muxxuContext; }
		
		/**
		 * Sets the session's token
		 */
		public function set token(token:Number):void { _token = token; }
		
		/**
		 * Gets the path finder map
		 */
		public function get pfMap():Array { return _pfMap; }
		
		/**
		 * Gets the current path
		 */
		public function get currentPath():Array { return _currentPath; }
		
		/**
		 * Gets if the model is locked
		 */
		public function get locked():Boolean { return _locked; }
						/* ****** *		 * PUBLIC *		 * ****** */
		/**
		 * Loads the revisions of a specific area
		 * 
		 * @param x			x position of the island to get the revisions of (ignored if offset is defined)
		 * @param y			y position of the island to get the revisions of (ignored if offset is defined)
		 * @param offset	offset of latest revisions to get.
		 */
		public function getRevisions(x:int, y:int, offset:int = -1, length:int = 10):void {
			var urlVars:URLVariables = new URLVariables();
			if(offset == -1) {
				urlVars.x		= x.toString();
				urlVars.y		= y.toString();
			}else{
				urlVars.offset	= offset.toString();
				urlVars.total	= length.toString();
			}
			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
			urlVars.world		= _currentWorld;
			urlVars.version		= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("getRevisions"));
            req.data			= RequestEncrypter.encrypt(urlVars);
			req.method			= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadRevisionsCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadRevisionsErrorHandler);
			loader.load(req);
		}
		
		/**
		 * Gets the items of a specific area.
		 */
		public function getUserOn(x:int, y:int, pseudo:String = null):void {
			var urlVars:URLVariables	= new URLVariables();
			if(pseudo == null) {
				urlVars.x		= x.toString();
				urlVars.y		= y.toString();
			}else{
				urlVars.pseudo	= pseudo;
			}
			urlVars.world		= _currentWorld;
			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version		= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("getUsersOn"));
            req.data			= RequestEncrypter.encrypt(urlVars);
			req.method			= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadUsersCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadUsersErrorHandler);
			loader.load(req);
		}
		
		/**
		 * Sets the user's position
		 */
		public function setPosition(x:int, y:int):void {
			if(_locked) return;
			
			_newPoustyPos		= new Point(x, y);
			var urlVars:URLVariables = new URLVariables();
			urlVars.x			= x.toString();
			urlVars.y			= y.toString();
			urlVars.world		= _currentWorld;
			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version		= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("setPosition"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, setPositionCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, setPositionErrorHandler);
			loader.load(req);
		}
		
		/**
		 * Gets the items of a specific area.
		 */
		public function loadArea(area:Rectangle = null, clearCache:Boolean = false, pathFinderMode:Boolean = false, getFLags:Boolean = false):void {
			if(_locked) return;
			
			lock();
			
			if(clearCache){
				cleanCacheHandler();
				_timerClean.reset();
			}
			_lastArea = (area == null) ? _lastArea : area;
			var urlVars:URLVariables	= new URLVariables();
			if(getFLags) {
				urlVars.getFlags= "1";
			}
			if(pathFinderMode) {
				urlVars.pathfinderMode	= "1";
			}else{
				urlVars.xmin	= _lastArea.left.toString();
				urlVars.ymin	= _lastArea.top.toString();
				urlVars.xmax	= _lastArea.right.toString();
				urlVars.ymax	= _lastArea.bottom.toString();
			}
			urlVars.token	= Math.round(new Date().getTime() / 1000).toString();
			urlVars.world	= _currentWorld;
			urlVars.version	= Constants.DATA_VERSION.toString();
			var req:URLRequest = new URLRequest(HTTPPath.getPath("loadArea"));
			
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadAreaCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadAreaErrorHandler);
			loader.load(req);
			_loaderToAreas[loader] = _lastArea;
		}

		/**
		 * Creates an area.
		 */
		public function createEntry(posX:int, posY:int, items:String, directions:String, enemies:String, data:String):void {
			if(_locked) return;
			
			var urlVars:URLVariables = new URLVariables();
			urlVars.x0		= posX.toString();
			urlVars.y0		= posY.toString();
			urlVars.d0		= directions;
			urlVars.i0		= items;
			urlVars.e0		= enemies;
			urlVars.data0	= data;
			urlVars.token	= Math.round(new Date().getTime() / 1000).toString();
			urlVars.world	= _currentWorld;
			urlVars.version	= Constants.DATA_VERSION.toString();
			var req:URLRequest = new URLRequest(HTTPPath.getPath("addArea"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, addAreaCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, addAreaErrorHandler);
			loader.load(req);
		}

		/**
		 * Updates an area.
		 */
		public function updateEntry(posX:int, posY:int, items:String, directions:String, enemies:String, data:String):void {
			if(_locked) return;
			
			createEntry(posX, posY, items, directions, enemies, data);
		}
		
		/**
		 * Gets the messages
		 */
		public function getMessages(offset:int = 0, length:int = 50):void {
			var urlVars:URLVariables	= new URLVariables();
			urlVars.offset				= offset.toString();
			urlVars.length				= length.toString();
			urlVars.token				= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version				= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("getMessages"));
            req.data			= RequestEncrypter.encrypt(urlVars);
			req.method			= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadMessagesCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadMessagesErrorHandler);
			loader.load(req);
		}

		/**
		 * Adds a message.
		 */
		public function addMessage(message:String, love:int):void {
			var urlVars:URLVariables = new URLVariables();
			urlVars.message	= message;
			urlVars.love	= love.toString();
			urlVars.token	= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version	= Constants.DATA_VERSION.toString();
			var req:URLRequest = new URLRequest(HTTPPath.getPath("addMessage"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, addMessageCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, addMessageErrorHandler);
			loader.load(req);
		}

		/**
		 * Adds a message.
		 */
		public function reportMessage(id:Number):void {
			var urlVars:URLVariables = new URLVariables();
			urlVars.id	= id.toString();
			urlVars.token	= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version	= Constants.DATA_VERSION.toString();
			var req:URLRequest = new URLRequest(HTTPPath.getPath("reportMessage"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, reportMessageCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, reportMessageErrorHandler);
			loader.load(req);
		}

		/**
		 * Asks for map rendering
		 */
		public function renderMap():void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.UPDATE_MAP));
		}
		
		/**
		 * Opens the tooltip of a specific zone.
		 */
		public function openZone(pos:Point):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.OPEN_ZONE, 0, new Rectangle(pos.x, pos.y)));
		}
		
		/**
		 * Logs in the user.
		 */
		public function logIn(uid:String, pubkey:String):void {
			_uid = uid;
			_pubkey = pubkey;
			var urlVars:URLVariables = new URLVariables();
			urlVars.uid			= uid;
			urlVars.pubkey		= pubkey;
			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version		= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("login"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loginCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loginErrorHandler);
			loader.load(req);
		}

		/**
		 * Logs out the user.
		 */
		public function logout():void {
			_isLogged = false;
			var urlVars:URLVariables = new URLVariables();
			urlVars.logout		= "true";
			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
			urlVars.version		= Constants.DATA_VERSION.toString();
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("login"));
            req.data	= RequestEncrypter.encrypt(urlVars);
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, logoutCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, logoutErrorHandler);
			loader.load(req);
		}
		
		/**
		 * Logs in the user.
		 */
		public function uploadData():void {
			if(_locked) return;
			
			lock();
			
			var req:URLRequest	= new URLRequest(HTTPPath.getPath("uploadData"));
            req.data	= SharedObjectManager.getInstance().json;
			req.method	= URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, uploadDataCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, uploadDataErrorHandler);
			loader.load(req);
		}

		/**
		 * Logs in the user.
		 */
//		public function downloadData():void {
//			var urlVars:URLVariables = new URLVariables();
//			urlVars.token		= Math.round(new Date().getTime() / 1000).toString();
//			urlVars.version		= DATA_VERSION.toString();
//			var req:URLRequest	= new URLRequest(HTTPPath.getPath("downloadData"));
//            req.data			= RequestEncrypter.encrypt(urlVars);
//			req.method			= URLRequestMethod.POST;
//			var loader:URLLoader = new URLLoader();
//			loader.addEventListener(Event.COMPLETE, downloadDataCompleteHandler);
//			loader.addEventListener(IOErrorEvent.IO_ERROR, downloadDataErrorHandler);
//			loader.load(req);
//		}

		/**
		 * Exports the flags.
		 */
		public function exportFlags():void {
			_fr = new FileReference();
			var data:ByteArray = new ByteArray();
			data.writeObject({v:SharedObjectManager.getInstance().visited, c:SharedObjectManager.getInstance().cleaned, o:SharedObjectManager.getInstance().gotObjects});
			_fr.save(data, "feverMap_marquages.fmf");
		}

		/**
		 * Imports a flags file.
		 */
		public function importFlags():void {
			_fr = new FileReference();
			_fr.browse([new FileFilter("FeverMap Flags file", "*.fmf")]);
			_fr.addEventListener(Event.SELECT, selectFileHandler);
			_fr.addEventListener(Event.COMPLETE, loadFileCompleteHandler);
		}

		/**
		 * Displays an application's message.
		 */
		public function showMessage(message:AppMessage):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.SHOW_APP_MESSAGE, 0, null, null, message));
		}

		/**
		 * Sets the objects filters
		 */
		public function setFilters(ids:Array):void {
			var i:int, len:int;
			_objectFiltersStr = ids.join(",");
			_objectFilters = [];
			for(i = 0; i < len; ++i) _objectFilters[ids[i]] = true;
			renderMap();
		}
		
		/**
		 * Searches for a path
		 */
		public function findPath(start:Point, end:Point, object:String = null):void {
			_objectToSearch = object;
			_pfStartPoint = start;
			_pfEndPoint = end;
			
			loadArea(null, false, true);
		}
		
		/**
		 * Clears the current path
		 */
		public function clearPath():void {
			_currentPath = null;
			dispatchEvent(new DataManagerEvent(DataManagerEvent.PATH_FINDER_PATH_FOUND));
		}
		
		/**
		 * Sets the current world to use
		 */
		public function setWorld(id:String):void {
			_currentWorld = id;
			SharedObjectManager.getInstance().currentWorld = id;
			loadArea(null, true, false, true);
		}

						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_loaderToAreas = new Dictionary();
			_objectFiltersStr = "";
			_objectFilters = [];
			_cache = [];
			_timerClean = new Timer(60000 * 5);//Clean cache every five minutes.
			_timerClean.addEventListener(TimerEvent.TIMER, cleanCacheHandler);
			_timerClean.start();
			_pfMapEmpty = new Array((_MAP_RADIUS+1) * 4 - 1);
			var i:int, len:int, j:int, lenJ:int;
			len = _pfMapEmpty.length;
			for(i = 0; i < len; ++i) {
				lenJ = (_MAP_RADIUS+1) * 4 - 1;
				_pfMapEmpty[i] = new Array(lenJ);
				for(j = 0; j < lenJ; ++j) {
					_pfMapEmpty[i][j] = 0;
				}
			}
			_currentWorld = SharedObjectManager.getInstance().currentWorld;
			SharedObjectManager.getInstance().addEventListener(SharedObjectManagerEvent.DATA_UPDATE, dataChangeHandler);
		}
		
		/**
		 * Locks the model
		 */
		private function lock():void {
			_locked = true;
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOCK));
		}
		
		/**
		 * Locks the model
		 */
		private function unlock():void {
			_locked = false;
			dispatchEvent(new DataManagerEvent(DataManagerEvent.UNLOCK));
		}
		
		/**
		 * Called when data change
		 */
		private function dataChangeHandler(event:SharedObjectManagerEvent):void {
			if(!SharedObjectManager.getInstance().firstVisit) {
				uploadData();
			}
		}
		
		/**
		 * Cleans the cache every X seconds.
		 */
		private function cleanCacheHandler(event:TimerEvent = null):void {
			_cache = [];
		}
		
		/**
		 * Checks if there are global actions to do.<br>
		 * <br>
		 * If there is an action done, the function returns true.
		 */
		private function checkGlobalActions(resultCode:int, data:XML):Boolean {
			if(resultCode == 200) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.NEED_APP_UPDATE, 200));
				return true;
			}
			
			var message:AppMessage = new AppMessage();
			if(resultCode >= 400) {
				message.dynamicPopulate(Label.getLabel("error"+resultCode), 2, false);
				dispatchEvent(new DataManagerEvent(DataManagerEvent.SHOW_APP_MESSAGE, 0, null, null, message));
				return true;
			}

			if(data != null && data.child("message") != undefined) {
				message.populate(data.child("message")[0]);
				dispatchEvent(new DataManagerEvent(DataManagerEvent.SHOW_APP_MESSAGE, 0, null, null, message));
				if(message.lock) {
					return true;
				}
			}
			
			return false;
		}
		
		
		
		//__________________________________________________________ REVISIONS

		/**
		 * Called when revisions loading completes.
		 */
		private function loadRevisionsCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			
			if(checkGlobalActions(resultCode, data)) return;
			
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				var collection:RevisionCollection = new RevisionCollection();
				collection.populate(data);
				if(parseBoolean(data.child("result").@track)) {
					dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_TRACKING_COMPLETE, 0, null, collection));
				}else{
					dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_REVISIONS_COMPLETE, 0, null, collection));
				}
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_REVISIONS_ERROR, resultCode, null));
			}
		}


		/**
		 * Called if revisions loading fails.
		 */
		private function loadRevisionsErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_REVISIONS_ERROR, 101));
		}
		
		
		
		
		
		//__________________________________________________________ FLAGS

		/**
		 * Called when an FMF file is selected.
		 */
		private function selectFileHandler(event:Event):void {
			_fr.load();
		}

		/**
		 * Called when FMF file loading completes.
		 */
		private function loadFileCompleteHandler(event:Event):void {
			var obj:Object;
			try {
				obj = _fr.data.readObject();
			} catch(error:Error) {
				var message:AppMessage = new AppMessage();
				message.dynamicPopulate(Label.getLabel("importFlagsError"), 2);
				dispatchEvent(new DataManagerEvent(DataManagerEvent.SHOW_APP_MESSAGE, 0, null, null, message));
				return;
			}
			SharedObjectManager.getInstance().visited = obj["v"];			SharedObjectManager.getInstance().cleaned = obj["c"];			SharedObjectManager.getInstance().gotObjects = obj["o"];
			renderMap();
		}
		
		
		
		
		//__________________________________________________________ LOAD AREAS
		
		/**
		 * Called when area data are received.
		 */
		private function loadAreaCompleteHandler(event:Event):void {
			unlock();
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			
			if(checkGlobalActions(resultCode, data)) return;
			
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				var json:String = data.child("data")[0];
				if(json != null) {
					SharedObjectManager.getInstance().json = json;
					dispatchEvent(new DataManagerEvent(DataManagerEvent.CENTER_MAP_ON_POUSTY, 0, _loaderToAreas[event.target], _items));
				}
				
				var i:int, len:int, nodes:XMLList, pos:Point, useCache:Boolean;
				nodes = data.child("items").child("item");
				len = nodes.length();
				if(data.child("pfMode") == undefined) {
					_items = new Vector.<MapEntry>();
					for(i = 0; i < len; ++i) {
						pos = new Point(parseInt(nodes[i].@x), parseInt(nodes[i].@y));
						useCache = _cache[pos.x+"_"+pos.y] != undefined && nodes[i] == MapEntry(_cache[pos.x+"_"+pos.y]).rawData;
						if(useCache) {
							_items[i] = _cache[pos.x+"_"+pos.y];
						}else{
							_cache[pos.x+"_"+pos.y] = 
							_items[i] = new MapEntry(pos.x, pos.y, new MapIslandEntry(pos, nodes[i]), nodes[i]);
						}
					}
					dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_AREA_COMPLETE, 0, _loaderToAreas[event.target], _items));
				}else{
//					var bmd:BitmapData = new BitmapData(_MAP_RADIUS*4, _MAP_RADIUS*4, true, 0);
					_pfMap = ObjectUtils.clone(_pfMapEmpty) as Array;
					for(i = 0; i < len; ++i) {
						pos = new Point(parseInt(nodes[i].@x), parseInt(nodes[i].@y));
						if(_objectToSearch != null) {
							if(String(nodes[i].@i).split(",").indexOf(_objectToSearch) > -1) {
								_pfEndPoint = pos;
							}
						}
						if(_pfMap[(pos.y + _MAP_RADIUS) * 2] == undefined || _pfMap[(pos.y + _MAP_RADIUS) * 2][(pos.x + _MAP_RADIUS) * 2] == undefined) continue;
						_pfMap[(pos.y + _MAP_RADIUS) * 2][(pos.x + _MAP_RADIUS) * 2] = 1;
//						bmd.setPixel32((pos.x + _MAP_RADIUS) * 2, (pos.y + _MAP_RADIUS) * 2, 0xffff0000);
						var directions:int = parseInt(nodes[i].@d, 2);
						//Right way
						if((directions + 1) % 2 == 0) {
							_pfMap[(pos.y + _MAP_RADIUS) * 2][(pos.x + _MAP_RADIUS) * 2 + 1] = 1;
//							bmd.setPixel32((pos.x + _MAP_RADIUS) * 2 + 1, (pos.y + _MAP_RADIUS) * 2, 0xffff0000);
						}
						//Left way
						if((directions >= 4 && directions <= 7) || (directions >= 12 && directions <= 15)) {
							_pfMap[(pos.y + _MAP_RADIUS) * 2][(pos.x + _MAP_RADIUS) * 2 - 1] = 1;
//							bmd.setPixel32((pos.x + _MAP_RADIUS) * 2 - 1, (pos.y + _MAP_RADIUS) * 2, 0xffff0000);
						}
						//Down way
						if(directions == 2 || directions == 3 || directions == 6 || directions == 7 || directions == 10 || directions == 11 || directions == 14 || directions == 15) {
							_pfMap[(pos.y + _MAP_RADIUS) * 2 + 1][(pos.x + _MAP_RADIUS) * 2] = 1;
//							bmd.setPixel32((pos.x + _MAP_RADIUS) * 2, (pos.y + _MAP_RADIUS) * 2 + 1, 0xffff0000);
						}
						//Up way
						if(directions >= 8) {
							_pfMap[(pos.y + _MAP_RADIUS) * 2 - 1][(pos.x + _MAP_RADIUS) * 2] = 1;
//							bmd.setPixel32((pos.x + _MAP_RADIUS) * 2, (pos.y + _MAP_RADIUS) * 2 - 1, 0xffff0000);
						}
					}
//					new FileReference().save(PNGEncoder.encode(bmd), "map.png");
					loadPathComplete();
				}
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_AREA_ERROR, resultCode, _loaderToAreas[event.target]));
			}
			delete _loaderToAreas[event.target];
		}
		
		/**
		 * Called if area data loading fails.
		 */
		private function loadAreaErrorHandler(event:IOErrorEvent):void {
			unlock();
			delete _loaderToAreas[event.target];
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_AREA_ERROR, 101, _lastArea));
		}
		
		
		
		
		//__________________________________________________________ ADD AREA
		
		/**
		 * Called when an area is added successfully.
		 */
		private function addAreaCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			} catch(error:Error) {
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 5 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_AREA_COMPLETE, 0, _lastArea, _items));
				loadArea(_lastArea);
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_AREA_ERROR, resultCode, _loaderToAreas[event.target]));
			}
		}
		
		/**
		 * Called if area add fails.
		 */
		private function addAreaErrorHandler(event:IOErrorEvent):void {
			delete _loaderToAreas[event.target];
			dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_AREA_ERROR, 101, _lastArea));
		}
		
		
		
		
		//__________________________________________________________ LOAD MESSAGES
		
		/**
		 * Called when messages are received.
		 */
		private function loadMessagesCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			
			if(checkGlobalActions(resultCode, data)) return;
			
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				var i:int, len:int, nodes:XMLList;
				nodes = data.child("items").child("item");
				len = nodes.length();
				var items:Vector.<Message> = new Vector.<Message>();
				for(i = 0; i < len; ++i) {
					items[i] = new Message();
					items[i].populate(nodes[i]);
				}
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_MESSAGE_COMPLETE, 0, null, items));
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_MESSAGE_ERROR, resultCode));
			}
		}
		
		/**
		 * Called if messages loading fails.
		 */
		private function loadMessagesErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOAD_MESSAGE_ERROR, 101));
		}
		
		
		
		
		//__________________________________________________________ ADD MESSAGE
		
		/**
		 * Called when a message is added successfully.
		 */
		private function addMessageCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			} catch(error:Error) {
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 5 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_MESSAGE_COMPLETE, 0, null, _items));
				getMessages();
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_MESSAGE_ERROR, resultCode));
			}
		}
		
		/**
		 * Called if message add fails.
		 */
		private function addMessageErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.ADD_MESSAGE_ERROR, 101));
		}
		
		
		
		
		//__________________________________________________________ REPORT MESSAGE
		
		/**
		 * Called when a message reporting completes
		 */
		private function reportMessageCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			} catch(error:Error) {
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode > 0) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.REPORT_MESSAGE_ERROR, resultCode));
			}else{
				getMessages();
			}
		}
		
		/**
		 * Called if a message reporting fails
		 */
		private function reportMessageErrorHandler(event:IOErrorEvent):void {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.REPORT_MESSAGE_ERROR, 101));
		}
		
		
		
		
		
		
		//__________________________________________________________ LOGIN
		
		/**
		 * Called when login completes.
		 */
		private function loginCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				var xml:XML = RequestEncrypter.decrypt(data.child("data")[0]);
				_isAdmin = xml.child("rights")[0] == "1";
				_currentWorld = xml.child("world")[0];
				Config.addVariable("SESSID", data.child("sessID")[0]);
				var json:String = data.child("json")[0];
				if(json != null && json.length > 0) {
					SharedObjectManager.getInstance().json = json;
				}
				_isLogged = true;
				if(_uid != null && _pubkey != null) {
//					if(SharedObjectManager.getInstance().rememberMe) {
						SharedObjectManager.getInstance().uid = _uid;
						SharedObjectManager.getInstance().pubkey = _pubkey;
//					}else{
//						SharedObjectManager.getInstance().uid = "";
//						SharedObjectManager.getInstance().pubkey = "";
//					}
				}
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOGIN_COMPLETE, 0));
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOGIN_ERROR, resultCode));
			}
		}

		/**
		 * Called if login fails.
		 */
		private function loginErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOGIN_ERROR, 101));
		}
		
		
		
		
		
		
		//__________________________________________________________ POSITION
		
		/**
		 * Called when user's position update completes.
		 */
		private function setPositionCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 3 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				SharedObjectManager.getInstance().playerPosition = _newPoustyPos;
				dispatchEvent(new DataManagerEvent(DataManagerEvent.UPDATE_POS_COMPLETE, 0));
				dispatchEvent(new DataManagerEvent(DataManagerEvent.UPDATE_MAP, 0));
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.UPDATE_POS_ERROR, resultCode));
			}
		}

		/**
		 * Called if user's position update fails.
		 */
		private function setPositionErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.UPDATE_POS_ERROR, 101));
		}
		
		/**
		 * Called when users of a specific position loading completes.
		 */
		private function loadUsersCompleteHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 2 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				var i:int, len:int, nodes:XMLList;
				nodes = data.child("users").child("user");
				len = nodes.length();
				var items:Vector.<User> = new Vector.<User>(len, true);
				for(i = 0; i < len; ++i) {
					items[i] = new User();
					items[i].populate(nodes[i]);
				}
				dispatchEvent(new DataManagerEvent(DataManagerEvent.GET_USERS_ON_COMPLETE, 0, null, items));
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.GET_USERS_ON_ERROR, resultCode));
			}
		}
		
		/**
		 * Called if users of a specific position loading fails.
		 */
		private function loadUsersErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.GET_USERS_ON_ERROR, 101));
		}
		
		
		
		
		
		
		//__________________________________________________________ LOGOUT
		
		/**
		 * Called when login completes.
		 */
		private function logoutCompleteHandler(event:Event):void {
			_isLogged = false;
			dispatchEvent(new DataManagerEvent(DataManagerEvent.LOGOUT_COMPLETE, 0));
		}

		/**
		 * Called if login fails.
		 */
		private function logoutErrorHandler(event:IOErrorEvent):void {
			// osef
		}
		
		
		
		
		//__________________________________________________________ DATA UPLOAD / DOWNLOAD
		
		/**
		 * Called when data upload completes.
		 */
		private function uploadDataCompleteHandler(event:Event):void {
			unlock();
			
			var loader:URLLoader = event.target as URLLoader;
			var resultCode:int;
			try{
				var data:XML = new XML(loader.data);
				resultCode = parseInt(data.child("result")[0]);
			}catch(error:Error){
				resultCode = 100;
			}
			
			if(checkGlobalActions(resultCode, data)) return;
			if(resultCode > 3 && resultCode < 100) resultCode = 100;
			if(resultCode == 0) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_UPLOAD_COMPLETE, resultCode));
			} else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_UPLOAD_ERROR, resultCode));
			}
		}
		
		/**
		 * Called if data upload fails.
		 */
		private function uploadDataErrorHandler(event:IOErrorEvent):void {
			unlock();
			
			dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_UPLOAD_ERROR, 101));

		}
		
		/**
		 * Called when data download completes.
		 */
//		private function downloadDataCompleteHandler(event:Event):void {
//			var loader:URLLoader = event.target as URLLoader;
//			var resultCode:int;
//			try{
//				var data:XML = new XML(loader.data);
//				resultCode = parseInt(data.child("result")[0]);
//			}catch(error:Error){
//				resultCode = 100;
//			}
//			if(checkGlobalActions(resultCode, data)) return;
//			if(resultCode > 3 && resultCode < 100) resultCode = 100;
//			if(resultCode == 0) {
//				SharedObjectManager.getInstance().json = data.child("data")[0];
//				dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_DOWNLOAD_COMPLETE, resultCode));
//			} else {
//				dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_DOWNLOAD_ERROR, resultCode));
//			}
//		}
		
		/**
		 * Called if data download fails.
		 */
//		private function downloadDataErrorHandler(event:IOErrorEvent):void {
//			dispatchEvent(new DataManagerEvent(DataManagerEvent.DATA_DOWNLOAD_ERROR, 101));
//		}
		
		
		
		//__________________________________________________________ PATH FINDER
		
		/**
		 * Called when map data is loaded for path finding.
		 */
		private function loadPathComplete():void {
			_pfStartPoint.x = _pfStartPoint.x * 2 + _MAP_RADIUS * 2;
			_pfStartPoint.y = _pfStartPoint.y * 2 + _MAP_RADIUS * 2;
			_pfEndPoint.x = _pfEndPoint.x * 2 + _MAP_RADIUS * 2;
			_pfEndPoint.y = _pfEndPoint.y * 2 + _MAP_RADIUS * 2;
			var map:Map = new Map(_pfMap[0].length, _pfMap.length);
			for(var y:Number = 0; y< _pfMap.length; y++)
			{
				for(var x:Number = 0; x< _pfMap[y].length; x++)
				{
					map.setTile(new BasicTile(1, new Point(x, y), _pfMap[y][x]==1));
				}
			}
			var astar:Astar = new Astar();
			astar.addAnalyzer(new WalkableAnalyzer());
			astar.addEventListener(AstarEvent.PATH_FOUND, pathFoundHandler);
			astar.addEventListener(AstarEvent.PATH_NOT_FOUND, pathNotFoundHandler);
			try {
				astar.getPath(new PathRequest(_pfStartPoint, _pfEndPoint, map));
			}catch(error:Error) {
//				trace(_pfStartPoint+" :: "+_pfEndPoint);
//				trace("ERROR :: "+error.message);
				dispatchEvent(new DataManagerEvent(DataManagerEvent.PATH_FINDER_NO_PATH_FOUND));
			}
		}
		
		/**
		 * Called when a path is found
		 */
		private function pathFoundHandler(event:AstarEvent):void {
			var path:Array = event.getPath().toArray();
			var i:int, len:int, pos:Point, lastPos:Point;
			len = path.length;
			_currentPath = [];
			for(i = 0; i < len; ++i) {
				pos = BasicTile(path[i]).getPosition().clone();
				pos.x = Math.floor(pos.x * .5 - _MAP_RADIUS);
				pos.y = Math.floor(pos.y * .5 - _MAP_RADIUS);
				if(lastPos != null && pos.toString() == lastPos.toString()){
					pos = BasicTile(path[i]).getPosition().clone();
					pos.x = Math.round(pos.x * .5 - _MAP_RADIUS);
					pos.y = Math.round(pos.y * .5 - _MAP_RADIUS);
					if(lastPos != null && pos.toString() == lastPos.toString()) continue;
				}
				_currentPath.push(pos);
				lastPos = pos;
			}
			dispatchEvent(new DataManagerEvent(DataManagerEvent.PATH_FINDER_PATH_FOUND));
		}
		
		/**
		 * Called if not path have been found
		 */
		private function pathNotFoundHandler(event:AstarEvent):void {
			dispatchEvent(new DataManagerEvent(DataManagerEvent.PATH_FINDER_NO_PATH_FOUND));
		}
			}}internal class SingletonEnforcer{}