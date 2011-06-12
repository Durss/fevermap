package com.muxxu.fever.fevermap.components.form {	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.text.CssTextField;
	import com.muxxu.fever.fevermap.components.tooltip.content.zone.ZoneEditor;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.components.map.MapEntry;
	import com.nurun.utils.number.NumberUtils;
	import flash.utils.Dictionary;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.display.DisplayObject;
	import com.nurun.components.button.IconAlign;
	import com.muxxu.fever.fevermap.components.button.FeverToggleButton;
	import gs.easing.Quad;
	import flash.events.Event;
	import gs.TweenLite;
	import com.muxxu.fever.graphics.ArrowRightGraphic;
	import com.muxxu.fever.graphics.ArrowLeftGraphic;
	import com.muxxu.fever.graphics.ArrowBottomGraphic;
	import com.muxxu.fever.graphics.ArrowTopGraphic;
	import com.nurun.utils.pos.PosUtils;
	import flash.display.Shape;
	import flash.display.Sprite;
		/**	 * 	 * @author Francois	 * @date 6 nov. 2010;	 */
	public class ZoneForm extends Sprite {

		private const _BT_WIDTH:int = 19;		
		private var _opened:Boolean;
		private var _mask:Shape;
		private var _container:Sprite;
		private var _arrowTop:FeverToggleButton;
		private var _arrowBottom:FeverToggleButton;
		private var _arrowLeft:FeverToggleButton;
		private var _arrowRight:FeverToggleButton;		private var _defaultPositions:Dictionary;
		private var _closing:Boolean;
		private var _data:MapEntry;
		private var _revisions:RevisionsPaginator;
		private var _map:ZoneEditor;
		private var _titleArrows:CssTextField;

										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ZoneForm</code>.		 */		public function ZoneForm() {			initialize();		}


						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the width of the component.		 */
		override public function get width():Number { return _opened ? _mask.width : 0; }				/**		 * Gets the height of the component.		 */		override public function get height():Number { return  _opened? _mask.height : 0; }		/**		 * Gets if the form is openend.		 */		public function get opened():Boolean { return _opened; }				/**		 * Gets the selected items.		 */		public function get items():String { return _map.objects.join(","); }				/**		 * Gets the enemies.		 */		public function get enemies():String { return _map.enemies.join(","); }				/**		 * Gets the map matrix in JSON format.		 */		public function get matrix():String { return _map.data; }				/**		 * Gets the selected directions.		 */		public function get directions():String {			var i:int, len:int, ret:int, arrows:Vector.<FeverToggleButton>, dirs:Array;
			arrows = new Vector.<FeverToggleButton>();
			arrows.push(_arrowTop, _arrowLeft, _arrowBottom, _arrowRight);
			len = arrows.length;			dirs = [8,4,2,1];			ret = 0;			for(i = 0; i < len; ++i) {				if(arrows[i].selected) {					ret += dirs[i];				}			}			return NumberUtils.toDigits(ret.toString(2), 4);		}				/**		 * Sets the selected directions.		 */		public function set directions(str:String):void {			if(str.length == 0) return;
			var dirs:Number = parseInt(str, 2);			if(dirs & 0x1 == 1) _arrowRight.selected = true;
			if(dirs >> 1 & 0x1 == 1) _arrowBottom.selected = true;
			if(dirs >> 2 & 0x1 == 1) _arrowLeft.selected = true;
			if(dirs >> 3 & 0x1 == 1) _arrowTop.selected = true;		}		/* ****** *		 * PUBLIC *		 * ****** */		/**		 * Opens the form.		 */		public function open():void {
			_opened = true;			if(_data != null) {				DataManager.getInstance().getRevisions(_data.x, _data.y);			}else{				_revisions.populate(null);				doOpen();			}		}				/**		 * Populates the component		 */		public function populate(data:MapEntry):void {			_data = data;			reset();			if(_data != null) {				directions	= _data.rawData.@d;				_map.populate(_data);				_map.open();			}		}				/**		 * Opens the form.		 */		public function close():void {			_closing = true;			TweenLite.to(_mask, .25, {ease:Quad.easeInOut, height:0, onUpdate:computePositions, onComplete:onHideComplete});		}

		/**		 * Resets the form.		 */
		public function reset():void {			_arrowBottom.selected = false;
			_arrowLeft.selected = false;
			_arrowRight.selected = false;
			_arrowTop.selected = false;			_map.reset();
		}

						/* ******* *		 * PRIVATE *		 * ******* */		/**		 * Initialize the class.		 */		private function initialize():void {			_mask		= addChild(new Shape()) as Shape;
			_container	= addChild(new Sprite()) as Sprite;			_titleArrows= _container.addChild(new CssTextField("menuContentTitle")) as CssTextField;			_arrowTop	= _container.addChild(createToggleButton(new ArrowTopGraphic())) as FeverToggleButton;			_arrowBottom= _container.addChild(createToggleButton(new ArrowBottomGraphic())) as FeverToggleButton;			_arrowLeft	= _container.addChild(createToggleButton(new ArrowLeftGraphic())) as FeverToggleButton;			_arrowRight	= _container.addChild(createToggleButton(new ArrowRightGraphic())) as FeverToggleButton;			_revisions	= _container.addChild(new RevisionsPaginator()) as RevisionsPaginator;			_map		= _container.addChild(new ZoneEditor()) as ZoneEditor;						_defaultPositions = new Dictionary();			
			_mask.graphics.beginFill(0xff0000, 0);			_mask.graphics.drawRect(0, 0, 100, 100);			_mask.graphics.endFill();						_titleArrows.text = Label.getLabel("mapEditDirection");			_titleArrows.background = true;			_titleArrows.backgroundColor = 0;			
			_container.mask = _mask;						_mask.height	= 0;						computePositions();						addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			_revisions.addEventListener(Event.RESIZE, computePositions);			_revisions.addEventListener(Event.CHANGE, revisionChangeHandler);			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_COMPLETE, loadRevisionsCompleteHandler);			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_ERROR, loadRevisionsErrorHandler);
		}
				/**		 * Called when the stage is available.		 */		private function addedToStageHandler(event:Event):void {			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		/**		 * Called when a key is released		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(!_opened) return;			
			if(event.keyCode == Keyboard.UP) {
				_arrowTop.selected = !_arrowTop.selected;
			} else if(event.keyCode == Keyboard.DOWN) {
				_arrowBottom.selected = !_arrowBottom.selected;
			} else if(event.keyCode == Keyboard.RIGHT) {
				_arrowRight.selected = !_arrowRight.selected;
			} else if(event.keyCode == Keyboard.LEFT) {
				_arrowLeft.selected = !_arrowLeft.selected;			}		}				/**		 * Does the opening transition		 */		private function doOpen():void {			computePositions();			TweenLite.to(_mask, .25, {ease:Quad.easeInOut, height:_container.height, onUpdate:computePositions});		}
		/**		 * Called when the hide transition completes		 */		private function onHideComplete():void {			computePositions();			_closing = false;			_opened = false;			_map.close();			dispatchEvent(new Event(Event.RESIZE));
		}

		/**		 * Creates a toggle button		 */
		private function createToggleButton(icon:DisplayObject):FeverToggleButton {
			var button:FeverToggleButton = new FeverToggleButton("", icon, icon);			button.iconAlign = IconAlign.CENTER;			button.width	= _BT_WIDTH * icon.scaleX;			button.height	= _BT_WIDTH * icon.scaleY;			return button; 
		}


		/**		 * Resizes and replaces the elements.		 */		private function computePositions(event:Event = null):void {
			var w:int = Math.max((_BT_WIDTH + 2) * 10 - 2, _map.width);
			PosUtils.vPlaceNext(10, _revisions, _map);						var availW:int = Math.round((_map.width - _revisions.width - 24));			_titleArrows.x = 0;			_titleArrows.width = availW;						_arrowTop.x = _arrowBottom.x = Math.round((availW - _arrowTop.width * 3) * .5 + _arrowTop.width);			_arrowTop.y = Math.round(_titleArrows.y + _titleArrows.height + 1);			_arrowLeft.x = Math.round(_arrowTop.x - _arrowLeft.width);			_arrowRight.x = Math.round(_arrowTop.x + _arrowRight.width);			_arrowLeft.y = _arrowRight.y = Math.round(_arrowTop.y + _arrowTop.height);
			_arrowBottom.y = Math.round(_arrowLeft.y + _arrowLeft.height);			
			_container.graphics.clear();			if(_opened) {				_container.graphics.beginFill(0xffffff, .15);				var py:int = _titleArrows.y + _titleArrows.height;
				_container.graphics.drawRect(_titleArrows.x, py, availW, _revisions.height - py);
				_container.graphics.endFill();			}						_revisions.x = Math.round(_map.width - _revisions.width - 12);//			_revisions.y = Math.round(_map.y + _map.height + 10);						PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _map);						_mask.width	= w;						dispatchEvent(new Event(Event.RESIZE));		}				/**		 * Called when a revision is selected		 */
		private function revisionChangeHandler(event:Event):void {
			var data:Revision = _revisions.revision;			reset();			directions	= data.directions;
			_map.populateRevision(data);		}														//__________________________________________________________ SERVER EVENTS				/**		 * Called when revisions loading completes.		 */		private function loadRevisionsCompleteHandler(event:DataManagerEvent):void {			_revisions.populate(event.items);			doOpen();		}		/**		 * Called if revisions loading fails.		 */		private function loadRevisionsErrorHandler(event:DataManagerEvent):void {			_revisions.populate(null);			doOpen();
		}
			}}