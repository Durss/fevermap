package com.muxxu.fever.fevermap.components.menu.tracker {

	import flash.events.Event;
	import com.nurun.core.lang.Disposable;
	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.array.ArrayUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 15 janv. 2011;
	 */
	public class MenuTracker extends AbstractMenuContent implements IMenuContent, Disposable {

		private static const _ITEMS_PER_PAGE:int = 15;

		private var _title:CssTextField;
		private var _revisionsHolder:Sprite;
		private var _tracks:Vector.<TrackItem>;
		private var _spin:SpinGraphic;
		private var _opened:Boolean;
		private var _captions:Sprite;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuTracker</code>.
		 */
		public function MenuTracker() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		override public function open():void {
			if(_opened) return;
			_opened = true;
			_container.addChild(_spin);
			if(_container.contains(_revisionsHolder)) _container.removeChild(_revisionsHolder);
			_container.graphics.clear();
			_container.graphics.beginFill(0xff0000, 0);
			_container.graphics.drawRect(0, 0, _title.width, 200);
			_container.graphics.endFill();
			_spin.x = _title.width * .5;
			_spin.y = 200 * .5;
			computePositions();
			DataManager.getInstance().getRevisions(0, 0, 0, _ITEMS_PER_PAGE);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			var i:int, len:int;
			len = _tracks.length;
			for(i = 0; i < len; ++i) {
				_tracks[i].clear();
				if(_revisionsHolder.contains(_tracks[i])) {
					_revisionsHolder.removeChild(_tracks[i]);
				}
			}
			_opened = false;
		}
		
		/**
		 * Sets the tabIndex start.
		 */
		public function setTabIndexes(value:int):int {
			return value;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			while(_captions.numChildren > 0) {
				if(_captions.getChildAt(0) is Disposable) Disposable(_captions.getChildAt(0)).dispose();
				_captions.removeChildAt(0);
			}
			
			while(_revisionsHolder.numChildren > 0) {
				if(_revisionsHolder.getChildAt(0) is Disposable) Disposable(_revisionsHolder.getChildAt(0)).dispose();
				_revisionsHolder.removeChildAt(0);
			}
			super.dispose();
			
			_captions.graphics.clear();
			
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOAD_TRACKING_COMPLETE, loadRevisionsCompleteHandler);
			removeEventListener(MouseEvent.CLICK, clickHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_revisionsHolder	= _container.addChild(new Sprite()) as Sprite;
			_title				= _container.addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_captions			= _container.addChild(new Sprite()) as Sprite;
			_spin				= new SpinGraphic();
			_title.text			= Label.getLabel("menuTrackTitle");
			
			var i:int, len:int, tf:CssTextField, colors:Array, px:int;
			len = _ITEMS_PER_PAGE;
			_tracks = new Vector.<TrackItem>(len, true);
			for(i = 0; i < len; ++i) {
				_tracks[i] = new TrackItem();
			}
			
			colors = [0x509101, 0x0000FF, 0xCC0000, 0xFFFF00, 0xcb9472];
			len = colors.length;
			_captions.graphics.clear();
			_captions.graphics.lineStyle(0,0,1);
			for(i = 0; i < len; ++i) {
				_captions.graphics.beginFill(colors[i], 1);
				_captions.graphics.drawRect(px, 0, 10, 10);
				_captions.graphics.endFill();
				px += 12;
				tf = _captions.addChild(new CssTextField("menuContentCaption")) as CssTextField;
				tf.text = Label.getLabel("menuTrackItemCaption"+(i+1));
				tf.x = px;
				tf.y = -3;
				px += Math.round(tf.width + 15);
			}
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_TRACKING_COMPLETE, loadRevisionsCompleteHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			
			computePositions();
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target is TrackItem) {
				DataManager.getInstance().openZone(TrackItem(event.target).pos);
			}
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions():void {
			PosUtils.hDistribute(ArrayUtils.toArray(_tracks), (103 + 10) * 5, 10, 10);
			
			_revisionsHolder.y = Math.round(_title.height + 10);
			_captions.y = Math.round(_revisionsHolder.y + _revisionsHolder.height + 30);
			
			super.computePositions();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called when revisions loading complete.
		 */
		private function loadRevisionsCompleteHandler(event:DataManagerEvent):void {
			if(_container.contains(_spin)) _container.removeChild(_spin);
			_container.addChild(_revisionsHolder);
			var i:int, len:int, items:Vector.<Revision>;
			items = event.items;
			len = items.length;
			for(i = 0; i < _ITEMS_PER_PAGE; ++i) {
				if(i < len) {
					_tracks[i].populate(items[i]);
					_revisionsHolder.addChild(_tracks[i]);
				}else{
					_tracks[i].clear();
					if(_revisionsHolder.contains(_tracks[i])) {
						_revisionsHolder.removeChild(_tracks[i]);
					}
				}
			}
			computePositions();
		}
		
	}
}