package com.muxxu.fever.fevermap.data {	import by.blooddy.crypto.serialization.JSON;	import com.muxxu.fever.fevermap.events.SharedObjectManagerEvent;	import com.nurun.utils.bytearray.ByteArrayUtils;	import com.nurun.utils.crypto.XOR;	import flash.errors.IllegalOperationError;	import flash.events.EventDispatcher;	import flash.events.TimerEvent;	import flash.geom.Point;	import flash.net.SharedObject;	import flash.utils.ByteArray;	import flash.utils.Timer;	/**	 * Singleton SharedObjectManager	 * 	 * @author Francois	 */	public class SharedObjectManager extends EventDispatcher{				private static var _instance:SharedObjectManager;
		private var _cache:Object;
		private var _so:SharedObject;
		private var _timerFlush:Timer;
								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>SharedObjectManager</code>.<br>		 */		public function SharedObjectManager(enforcer:SingletonEnforcer) {			if(enforcer == null) throw new IllegalOperationError("A singleton cannot be instanciated!");			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Singleton instance getter		 */		public static function getInstance():SharedObjectManager {			if(_instance == null)_instance = new  SharedObjectManager(new SingletonEnforcer());			return _instance;			}				/**		 * Gets the current world to use.		 */		public function get currentWorld():String { return getData("currentWorld", "0", true); }				/**		 * Sets the current world to use.		 */		public function set currentWorld(value:String):void {			setData("currentWorld", value, true);			_timerFlush.reset();			_timerFlush.stop();		}				/**		 * Gets the current render mode.		 * 0 = normal		 * 1 = path		 */		public function get renderMode():int { return getData("renderMode", 0); }				/**		 * Sets the current render mode.		 */		public function set renderMode(value:int):void { setData("renderMode", value); }				/**		 * Gets if the application should be reduced on the traybar.		 */		public function get reduceOnTraybar():Boolean { return getData("systrayReduce", true, true); }				/**		 * Sets if the application should be reduced on the traybar.		 */		public function set reduceOnTraybar(value:Boolean):void { setData("systrayReduce", value, true); }						/**		 * Gets if the window should be always on top.		 */		public function get alwaysInFront():Boolean { return getData("alwaysInFront", true, true); }				/**		 * Sets if the window should be always on top.		 */		public function set alwaysInFront(value:Boolean):void { setData("alwaysInFront", value, true); }						/**		 * Gets if the tuto is read		 */		public function get tutoRead():Boolean { return getData("tutoRead", false); }				/**		 * Sets if the tuto is read		 */		public function set tutoRead(value:Boolean):void { setData("tutoRead", value); }						/**		 * Gets the local/online mode state.		 */		public function get localMode():Boolean { return getData("isLocal", false, true); }				/**		 * Sets the local/online mode state.		 */		public function set localMode(value:Boolean):void {			setData("isLocal", value, true);			_so.flush();		}						/**		 * Gets the rememberMe state.		 */		public function get rememberMe():Boolean { return getData("rememberMe", false, true); }				/**		 * Sets the rememberMe state.		 */		public function set rememberMe(value:Boolean):void {			setData("rememberMe", value, true);			_so.flush();		}						/**		 * Gets the spoil state.		 */		public function get spoil():Boolean { return getData("spoil", true); }				/**		 * Sets the spoil state.		 */		public function set spoil(value:Boolean):void { setData("spoil", value); }						/**		 * Gets if the got object should be displayed or not.		 */		public function get sgObjects():Boolean { return getData("sgObjects", false); }				/**		 * Sets if the got object should be displayed or not.		 */		public function set sgObjects(value:Boolean):void { setData("sgObjects", value); }						/**		 * Gets the glow spoil state.		 */		public function get spoilGlow():Boolean { return getData("spoilGlow", true); }				/**		 * Sets the glow spoil state.		 */		public function set spoilGlow(value:Boolean):void { setData("spoilGlow", value); }						/**		 * Gets the glow diffObjects state.		 */		public function get diffObjects():Boolean { return getData("diffObjects", false); }				/**		 * Sets the glow diffObjects state.		 */		public function set diffObjects(value:Boolean):void { setData("diffObjects", value); }						/**		 * Gets the user's login.		 */		public function get uid():String { return getData("uid", "", true); }				/**		 * Sets the user's ID.		 */		public function set uid(value:String):void {			setData("uid", value, true);			_so.flush();			_timerFlush.reset();			_timerFlush.stop();		}						/**		 * Gets the user's pubkey.		 */		public function get pubkey():String {			var str:String = getData("pubkey", "", true);
						if(str.length == 0) return "";			var ret:String;
			try {				var ba:ByteArray = ByteArrayUtils.fromString(str, 36);				XOR(ba, "ds#dD_2");				ret = ba.readUTF();			}catch(error:Error) {				ret = "";			}			return ret;		}				/**		 * Sets the user's pass.		 */		public function set pubkey(value:String):void {			var ba:ByteArray = new ByteArray();			ba.writeUTF(value);			XOR(ba, "ds#dD_2");
			setData("pubkey", ByteArrayUtils.toString(ba, 36), true);			_so.flush();			_timerFlush.reset();			_timerFlush.stop();		}						/**		 * Gets the current position.		 *///		public function get currentPosition():Point {//			var obj:Object = getData("curPos", {x:0,y:0});//			return new Point(obj.x, obj.y);//		}				/**		 * Sets the current position.		 *///		public function set currentPosition(value:Point):void {//			setData("curPos", {x:value.x,y:value.y});//		}						/**		 * Gets the current position of the player.		 */		public function get playerPosition():Point {			var obj:Object = getData("poustyPos", {x:0,y:0});			return new Point(obj.x, obj.y);		}				/**		 * Sets the current position of the player.		 */		public function set playerPosition(value:Point):void {			setData("poustyPos", {x:value.x, y:value.y});		}						/**		 * Gets if it's the first visit.		 *///		public function get firstVisit():Boolean { return getData("firstVisit", true); }		public function get firstVisit():Boolean { 			for(var i:String in _cache) {				i;//Avoid from unused warnings
				return false;
			}			return true;		}				/**		 * Sets if it's the first visit.		 *///		public function set firstVisit(value:Boolean):void {//			setData("firstVisit", value);//			flush(false);//		}						/**		 * Gets if there is something flagged		 *///		public function get isSomethingFlagged():Boolean {//			var i:String;//			var c:Object = cleaned;//			var v:Object = visited;//			var o:Object = getData("gotObjects", {});//			//			for (i in c) return true;//			for (i in v) return true;//			for (i in o) return true;//			return false;
//		}						/**		 * Gets the cleaned areas.		 */		public function get cleaned():Object { return getData("cleaned", {}); }				/**		 * Sets the cleaned areas.		 */		public function set cleaned(value:Object):void { setData("cleaned", value); }				/**		 * Gets the visited areas.		 */		public function get visited():Object { return getData("visited", {}); }				/**		 * Sets the visited areas.		 */		public function set visited(value:Object):void { setData("visited", value); }				/**		 * Gets the got objects.		 */		public function get gotObjects():Object { return getData("gotObjects", {}); }				/**		 * Sets the got objects.		 */		public function set gotObjects(value:Object):void { setData("gotObjects", value); }						/**		 * Gets the data as JSON.		 */		public function get json():String {			/*			delete _so.data["pass"];			var obj:Object = ObjectUtils.clone(_so.data);			delete obj["isLocal"];			delete obj["firstVisit"];			delete obj["rememberMe"];			//AS JSON is not fuckin' able to encode associative arrays, we			//convert them into object (and actually it should have been objects			//instead of arrays.. but too late!						var i:String, d:Object;			d = {};			for (i in obj.cleaned) d[i] = obj.cleaned[i];			obj.cleaned = d;						d = {};			for (i in obj.visited) d[i] = obj.visited[i];			obj.visited = d;						d = {};			for (i in obj.gotObjects) d[i] = obj.gotObjects[i];			obj.gotObjects = d;			
			return JSON.encode(obj);			 */			return by.blooddy.crypto.serialization.JSON.encode(_cache);		}						/**		 * Sets the data as JSON.		 */		public function set json(value:String):void {			if(value.length == 0) {				//Create the default data and fire the update to save it								var splayerPos:Point, srenderMode:int, stutoRead:Boolean, sspoil:Boolean, ssgObject:Boolean;				var sspoilGlow:Boolean, sdiffObjects:Boolean;				splayerPos = new Point();				if(!firstVisit) {					srenderMode = renderMode;					stutoRead = tutoRead;					sspoil = spoil;					ssgObject = sgObjects;					sspoilGlow = spoilGlow;					sdiffObjects = diffObjects;				}else{					srenderMode = 0;					stutoRead = false;					sspoil = false;					ssgObject = false;					sspoilGlow = false;					sdiffObjects = false;				}				_cache = {};								playerPosition = splayerPos;				renderMode = srenderMode;				tutoRead = stutoRead;				spoil = sspoil;				sgObjects = ssgObject;				spoilGlow = sspoilGlow;				diffObjects = sdiffObjects;								dispatchEvent(new SharedObjectManagerEvent(SharedObjectManagerEvent.DATA_UPDATE));				return;			}			var data:Object = by.blooddy.crypto.serialization.JSON.decode(value);			//Clean old stuff			delete data["firstVisit"];			delete data["uid"];			delete data["lastFlush"];			delete data["pubkey"];			delete data["login"];			delete data["dolTouch"];			delete data["rememberMe"];			delete data["pass"];			_cache = data;			/*			var data:Object = JSON.decode(value);			var save:Object = {};			save["isLocal"] = localMode;			save["rememberMe"] = rememberMe;			save["firstVisit"] = firstVisit;			_so.clear();						var i:String, d:Array;			
			for (i in data) {				if(i == "firstVisit" || i == "isLocal" || i == "rememberMe") continue;				_so.data[i] = data[i];			}						for (i in save) {				_so.data[i] = save[i];			}						d = [];			for (i in _so.data.cleaned) d[i] = _so.data.cleaned[i];			_so.data.cleaned = d;						d = [];			for (i in _so.data.visited) d[i] = _so.data.visited[i];			_so.data.visited = d;						d = [];			for (i in _so.data.gotObjects) d[i] = _so.data.gotObjects[i];			_so.data.gotObjects = d;						_cache = new Dictionary();			//			_timerFlush.reset();//			_timerFlush.stop();			 */		}						/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Gets a SharedObject's data		 * 		 * @param id		datas ID.		 * @param value		data's value.		 * @param storeOnCookies	defines if the data should be stored on the local shared object.		 */		public function setData(id:String, value:*, storeOnCookies:Boolean = false):void {			if(storeOnCookies) {				_so.data[id] = value;
			}else{				_cache[id] = value;			}			flush(true);		}		/**		 * Gets a SharedObject's data.<p>		 * 		 * @param id			datas ID.		 * @param defaultValue	default value returned if the data does not exist yet.		 * 		 * @return	the data's value or the defaultValue parameter.		 */		public function getData(id:String, defaultValue:*, getFromSO:Boolean = false):* {			if(getFromSO) { //_so.data[id] != null) {				return _so.data[id] == undefined? defaultValue : _so.data[id];			}else{				if(_cache[id] == undefined) {					_cache[id] = defaultValue;
				}				return _cache[id];			}//			if(_cache[id] == undefined) {//				if(_so.data[id] == null) {//					_so.data[id] = defaultValue;//					_cache[id] = defaultValue;//					return defaultValue;//				}else{//					_cache[id] =_so.data[id];//				}//			}//			return _cache[id];		}				/**		 * Gets if an area has been visited.		 */		public function isAreaVisited(area:Point):Boolean {			return getData("visited", {})[area.x + ":" + area.y] === true;		}				/**		 * Flags an area as visited.		 */		public function flagAreaAsVisited(area:Point):void {			var d:Object = getData("visited", {});			d[area.x + ":" + area.y] = true;			setData("visited", d);		}				/**		 * Flags an area as visited.		 */		public function flagAreaAsNonVisited(area:Point):void {			var d:Object = getData("visited", {});			delete d[area.x + ":" + area.y];			setData("visited", d);		}				/**		 * Gets if an area has been cleaned.		 */		public function isAreaCleaned(area:Point):Boolean {			return getData("cleaned", {})[area.x + ":" + area.y] === true;		}				/**		 * Flags an area as cleaned.		 */		public function flagAreaAsCleaned(area:Point):void {			var d:Object = getData("cleaned", {});			d[area.x + ":" + area.y] = true;			setData("cleaned", d);		}				/**		 * Flags an area as cleaned.		 */		public function flagAreaAsNonCleaned(area:Point):void {			var d:Object = getData("cleaned", {});			delete d[area.x + ":" + area.y];			setData("cleaned", d);		}				/**		 * Gets the got objects of an area		 */		public function getGotObjectsByArea(area:Point):Array {			var ret:Array = getData("gotObjects", {})[area.x + ":" + area.y];			return ret == null? [] : ret;		}				/**		 * Sets the got objects of an area		 */		public function setGotObjectsOfArea(area:Point, objects:Array):void {			var d:Object = getData("gotObjects", {});			d[area.x + ":" + area.y] = objects;			setData("gotObjects", d);		}								/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initializes some vars and the statics sharedObjects.<br>		 */		private function initialize():void {			_cache = {};			_so = SharedObject.getLocal("feverMap", "/");			//Some cleaning of the old shits//			for(var i:String in _so.data) {
//				if(i != "uid" && i != "pubkey" && i != "rememberMe" &&  i != "isLocal") {//					delete _so.data[i];
//				}//			}			if(_so.data["v"] != "1") {				_so.clear();				_so.data["v"] = "1";			}			//TODO alonger cette durée et mettre un test des données les plus récentes			//entre BDD et local sur le DL.			_timerFlush = new Timer(5000, 1);			_timerFlush.addEventListener(TimerEvent.TIMER_COMPLETE, timerFlushCompleteHandler);
		}				/**		 * Forces flush.		 */		private function flush(upload:Boolean = true):void {			if(upload) {				_timerFlush.reset();				_timerFlush.start();				dispatchEvent(new SharedObjectManagerEvent(SharedObjectManagerEvent.TIMER_SAVE_START));			}else{				_so.flush();//If *100 it asks for 1Mo instead of 100Ko -_-//				_so.flush(1000 * 99);//If *100 it asks for 1Mo instead of 100Ko -_-			}		}				/**		 * Forces SO save.		 */
		private function timerFlushCompleteHandler(event:TimerEvent = null):void {			_timerFlush.stop();			flush(false);			dispatchEvent(new SharedObjectManagerEvent(SharedObjectManagerEvent.DATA_UPDATE));
		}
	}}internal class SingletonEnforcer{}