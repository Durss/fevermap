package com.muxxu.fever.fevermap.components.tooltip.content {

	import gs.TweenLite;

	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.components.form.ObjectsFlagger;
	import com.muxxu.fever.fevermap.components.form.ZoneForm;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.muxxu.fever.fevermap.components.map.icons.MapIslandEntry;
	import com.muxxu.fever.fevermap.components.tooltip.content.zone.ZoneSummary;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.graphics.PoustyGraphic;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.muxxu.fever.graphics.UpdateBmp;
	import com.muxxu.fever.graphics.ZoomInBmp;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.text.TextBounds;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
		/**	 * 	 * @author  Francois	 */	public class TTZoneContent extends Sprite implements ToolTipContent, Disposable {		private var _canBedisposed:Boolean;		private var _tf:CssTextField;
		private var _spin:SpinGraphic;
		private var _data:MapEntry;
		private var _posX:int;
		private var _posY:int;
		private var _width:Number;
		private var _height:Number;
		private var _updateBt:FeverButton;
		private var _form:ZoneForm;
		private var _visited:FeverButton;
		private var _isVisited:Boolean;
		private var _locked:Boolean;
		private var _buttonsCtn:Sprite;
		private var _cleaned:FeverButton;
		private var _isCleaned:Boolean;
		private var _fullMode:Boolean;
		private var _admin:Boolean;
		private var _summary:ZoneSummary;
		private var _objects:ObjectsFlagger;
		private var _imHere:FeverButton;
		private var _whosThere:FeverButton;
		private var _goThere:FeverButton;
										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>TTZoneContent</code>.		 */		public function TTZoneContent(canBedisposed:Boolean = true) {			_canBedisposed = canBedisposed;			initialize();		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets if the content is interactive or not.		 */		public function get isInteractive():Boolean { return _data != null || DataManager.getInstance().isAdmin; }
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _height; }

		/**
		 * Gets if the content is locked.
		 */
		public function get locked():Boolean { return _locked; }
		
		/**
		 * Gets if the content is opened
		 */
		public function get fullMode():Boolean { return _fullMode; }		
		/**
		 * Gets if on edit mode
		 */
		public function get editMode():Boolean { return _form.opened; }		/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Populates the content		 */
		public function populate(px:int, py:int, data:MapEntry):void {
			if(_locked) return;
			
			if(_fullMode){
				_form.close();
				removeChild(_buttonsCtn);
				removeChild(_form);
				addChild(_summary);
			}
			_fullMode = false;
						_data = data;			_posX = px;
			_posY = py;
			
			_tf.text = Label.getLabel("mapEngineAreaCoords").replace(/\$\{x\}/gi, px).replace(/\$\{y\}/gi, py);
			_summary.populate(data);
			
			computePositions();		}

		/**
		 * Displays the full content.
		 */
		public function displayFull():void {
			addChild(_buttonsCtn);
			addChild(_form);
			if(contains(_summary)) removeChild(_summary);
			
			_fullMode = true;
			
			_updateBt.label = _data == null? Label.getLabel("createMapEntry") : Label.getLabel("updateMapEntry");

			_isVisited		= !SharedObjectManager.getInstance().isAreaVisited(new Point(_posX, _posY));
			_isCleaned		= !SharedObjectManager.getInstance().isAreaCleaned(new Point(_posX, _posY));
			 
			_visited.label	= _isVisited ? Label.getLabel("flagAreaAsVisited") : Label.getLabel("flagAreaAsNonVisited");
			_cleaned.label	= _isCleaned ? Label.getLabel("flagAreaAsCleaned") : Label.getLabel("flagAreaAsNonCleaned");
			
			_form.populate(_data);
			_objects.populate(_data, new Point(_posX, _posY));
			
			if(_data != null) {
				_visited.enabled	= true;
				_cleaned.enabled	= true;
			} else {
				_visited.enabled	= false;
				_cleaned.enabled	= false;
			}

			if(!_admin && DataManager.getInstance().isAdmin) {
				_admin = true;
				_buttonsCtn.addChild(_updateBt);
			}
			if(!_admin){
				if(_buttonsCtn.contains(_updateBt)) {
					_buttonsCtn.removeChild(_updateBt);
				}
			}
			
			computePositions();
		}				/**		 * Makes the component garbage collectable.		 */		public function dispose():void {			if(_canBedisposed){				_tf.text = "";				while(numChildren > 0){ removeChildAt(0); }					_tf = null;			}		}
		
		/**
		 * Locks the view
		 */
		public function lock():void {
			addChild(_spin);
			_locked = true;
			mouseChildren = mouseEnabled = false;			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {alpha:.25});
		}
		
		/**
		 * Unlocks the view
		 */
		public function unlock():void {
			_locked = false;
			if(contains(_spin)) removeChild(_spin);
			mouseChildren = mouseEnabled = true;
			TweenLite.killTweensOf(this);
			TweenLite.to(this, .25, {alpha:1});		}
						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initializes the class.		 */		private function initialize():void {			_tf			= addChild(new CssTextField("tooltipContent")) as CssTextField;
			_buttonsCtn	= new Sprite();
			_updateBt	= new FeverButton("", new Bitmap(new UpdateBmp(NaN, NaN)));			_imHere		= _buttonsCtn.addChild(new FeverButton(Label.getLabel("flagAreaImHere"), new PoustyGraphic())) as FeverButton;
			_whosThere	= _buttonsCtn.addChild(new FeverButton(Label.getLabel("flagAreaWhosThere"), new PoustyGraphic())) as FeverButton;			_visited	= _buttonsCtn.addChild(new FeverButton(Label.getLabel("flagAreaAsVisited"), new Bitmap(new UpdateBmp(NaN, NaN)))) as FeverButton;
			_cleaned	= _buttonsCtn.addChild(new FeverButton(Label.getLabel("flagAreaAsCleaned"), new Bitmap(new UpdateBmp(NaN, NaN)))) as FeverButton;
			_goThere	= _buttonsCtn.addChild(new FeverButton(Label.getLabel("flagAreaFinPath"), new Bitmap(new ZoomInBmp(NaN, NaN)))) as FeverButton;
			_objects	= addChild(new ObjectsFlagger()) as ObjectsFlagger;
			_form		= addChild(new ZoneForm()) as ZoneForm;
			_summary	= addChild(new ZoneSummary()) as ZoneSummary;			_spin		= new SpinGraphic();
			
			_cleaned.icon.visible = false;
			_visited.icon.visible = false;
			_cleaned.iconAlign = IconAlign.CENTER;
			_visited.iconAlign = IconAlign.CENTER;
			_cleaned.textAlign = TextAlign.CENTER;
			_visited.textAlign = TextAlign.CENTER;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			_form.addEventListener(Event.RESIZE, computePositions);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_AREA_COMPLETE, serverResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.ADD_AREA_ERROR, serverResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.UPDATE_POS_COMPLETE, serverResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.UPDATE_POS_ERROR, serverResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_COMPLETE, serverResultHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_ERROR, serverResultHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		/**
		 * Called on server's result.
		 */
		private function serverResultHandler(event:DataManagerEvent):void {
			unlock();
			if(event.type == DataManagerEvent.ADD_AREA_ERROR) {
				_updateBt.label = Label.getLabel("submitFormError");
			} else if(event.type == DataManagerEvent.ADD_AREA_COMPLETE) {
				_updateBt.label = _data == null? Label.getLabel("createMapEntry") : Label.getLabel("updateMapEntry");
				_form.close();
			} else if(event.type == DataManagerEvent.UPDATE_POS_COMPLETE) {
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		/**		 * Resizes and replaces the elements.		 */		private function computePositions(event:Event = null):void {			var bounds:Rectangle = TextBounds.getBounds(_tf);
			
			_objects.visible = false;			_cleaned.validate();
			_visited.validate();
			_imHere.validate();
			_goThere.validate();
			_updateBt.validate();
			_cleaned.x = Math.round(_visited.width + 5);
			_imHere.x = Math.round(_cleaned.x + _cleaned.width + 5);
//			_whosThere.x = Math.round(_imHere.x + _imHere.width + 5);
			_goThere.x = _whosThere.width + 5;
			if(_fullMode) {
				if(_admin) {
					_updateBt.x = Math.round((_imHere.x + _imHere.width - _updateBt.width) * .5);
					_cleaned.y = _visited.y = _imHere.y = Math.round(_updateBt.height + 5);
				}
				_whosThere.y = _goThere.y = Math.round(_cleaned.y + _cleaned.height + 5);
				
				if(_form.opened) {
					PosUtils.vPlaceNext(10, _tf, _form, _buttonsCtn);
					PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _tf,  _form, _buttonsCtn);
				}else{
					_objects.visible = true;
					if(_objects.length > 0) {
						PosUtils.vPlaceNext(10, _tf, _objects, _buttonsCtn);
						PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _tf, _objects, _buttonsCtn);
					}else{
						PosUtils.vPlaceNext(10, _tf, _buttonsCtn);
						PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _tf, _buttonsCtn);
					}
				}
				_height = Math.round(_buttonsCtn.y + _buttonsCtn.height + 2);
				_width = Math.max(bounds.width, _form.width, _buttonsCtn.width);
			} else {
				PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _tf, _summary);
				PosUtils.vPlaceNext(10, _tf, _summary);
				if(_summary.height > 0) {
					_height = Math.round(_summary.y + _summary.height);
					_width = Math.max(_tf.width + 1, _summary.x + _summary.width);
				} else {
					_height = Math.round(_tf.height + 4);
					_width = Math.round(_tf.width + 1);
				}
			}
			
			_spin.x = _width * .5;
			_spin.y = _height * .5;
						dispatchEvent(new Event(Event.RESIZE));		}

		/**
		 * Called when a key is released
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.ENTER && _form.opened) {
				clickHandler(event);
			}
		}				/**		 * Called when a button is clicked.		 */		private function clickHandler(event:Event):void {
			var target:DisplayObject = event.target as BaseButton;
			if(target == _updateBt || (event is KeyboardEvent && _updateBt.enabled)) {
				lock();
				if(_form.opened) {
					if(_data == null) {
						DataManager.getInstance().createEntry(_posX, _posY, _form.items, _form.directions, _form.enemies.toString(), _form.matrix);
					} else {
						_data.rawData.@i = _form.items;						_data.rawData.@d = _form.directions;						_data.rawData.@e = _form.enemies;
						_data.rawData.@data = _form.matrix;
						MapIslandEntry(_data.icon).update();						DataManager.getInstance().renderMap();
						DataManager.getInstance().updateEntry(_posX, _posY, _data.rawData.@i, _data.rawData.@d, _data.rawData.@e, _data.rawData.@data);
					}
				} else {
					_updateBt.label = Label.getLabel("submitForm");
					_form.open();
					if(_data == null) {
						trace("TTZoneContent.clickHandler(event)");
						unlock();
					}
				}
				computePositions();
			} else if(target == _visited) {
				_isVisited = !_isVisited;
				if(!_isVisited) {
					SharedObjectManager.getInstance().flagAreaAsVisited(new Point(_posX, _posY));
				}else{
					SharedObjectManager.getInstance().flagAreaAsNonVisited(new Point(_posX, _posY));
				}
				MapIslandEntry(_data.icon).update();				DataManager.getInstance().renderMap();
				dispatchEvent(new Event(Event.CLOSE));
			} else if(target == _cleaned) {
				_isCleaned = !_isCleaned;
				if(!_isCleaned) {
					SharedObjectManager.getInstance().flagAreaAsVisited(new Point(_posX, _posY));
					SharedObjectManager.getInstance().flagAreaAsCleaned(new Point(_posX, _posY));
				}else{
					SharedObjectManager.getInstance().flagAreaAsNonCleaned(new Point(_posX, _posY));
				}
				MapIslandEntry(_data.icon).update();
				DataManager.getInstance().renderMap();
				dispatchEvent(new Event(Event.CLOSE));
			} else if(target == _imHere) {
				lock();
				SharedObjectManager.getInstance().flagAreaAsVisited(new Point(_posX, _posY));
				DataManager.getInstance().setPosition(_posX, _posY);
			} else if(target == _whosThere) {
				DataManager.getInstance().getUserOn(_posX, _posY);
				dispatchEvent(new Event(Event.CLOSE));
			} else if(target == _goThere) {
				DataManager.getInstance().findPath(SharedObjectManager.getInstance().playerPosition, new Point(_posX, _posY));
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
			}}