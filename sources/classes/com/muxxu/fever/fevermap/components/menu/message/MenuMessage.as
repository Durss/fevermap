package com.muxxu.fever.fevermap.components.menu.message {

	import com.muxxu.fever.fevermap.components.menu.AbstractMenuContent;
	import com.muxxu.fever.fevermap.components.menu.IMenuContent;
	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.data.SharedObjectManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.Message;
	import com.muxxu.fever.graphics.SpinGraphic;
	import com.muxxu.fever.graphics.WarningIconGraphic;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.scroll.ScrollPane;
	import com.nurun.components.scroll.scrollable.ScrollableDisplayObject;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.date.DateUtils;

	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;
	
	/**
	 * 
	 * @author Francois
	 * @date 26 janv. 2011;
	 */
	public class MenuMessage extends AbstractMenuContent implements IMenuContent {
		
		private const _WIDTH:int = 400;
		private const _COLORS:Array = [0x80D147, 0xd2d217, 0xDB9B3E, 0xDB3E3E, 0x999999, 0];
			
		private var _title:CssTextField;
		private var _spin:SpinGraphic;
		private var _opened:Boolean;
		private var _scrollpane:ScrollPane;
		private var _scroller:FeverScrollBar;
		private var _scrollable:ScrollableDisplayObject;
		private var _form:MenuMessageForm;
		private var _reportToId:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MenuMessage</code>.
		 */
		public function MenuMessage() {
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function setTabIndexes(value:int):int {
			return _form.setTabIndexes(value);
		}



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
			if(_container.contains(_scrollpane)) _container.removeChild(_scrollpane);
			_container.graphics.clear();
			_container.graphics.beginFill(0xff0000, 0);
			_container.graphics.drawRect(0, 0, _title.width, 200);
			_container.graphics.endFill();
			_spin.x = _title.width * .5;
			_spin.y = Math.round(_title.height + _spin.height);
			DataManager.getInstance().getMessages(0);
			computePositions();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			_scrollpane.width = _scrollpane.height = 0;
			_scrollable.content.graphics.clear();
			while(_scrollable.content.numChildren > 0) { _scrollable.content.removeChildAt(0); }
			_opened = false;
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		override public function dispose():void {
			super.dispose();
			
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOAD_MESSAGE_COMPLETE, messageUpdateHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			_scrollable = new ScrollableDisplayObject();
			_scroller = new FeverScrollBar();
			_scrollpane = _container.addChild(new ScrollPane(_scrollable, _scroller)) as ScrollPane;
			_title	= _container.addChild(new CssTextField("menuContentTitle")) as CssTextField;
			_spin	= _container.addChild(new SpinGraphic()) as SpinGraphic;
			_form = _container.addChild(new MenuMessageForm(_COLORS)) as MenuMessageForm;
			
			_title.text = Label.getLabel("menuMessageTitle");
			
			_title.width = _WIDTH;
			_title.background = true;
			_title.backgroundColor = 0;
			
			_scrollpane.autoHideScrollers = false;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_MESSAGE_COMPLETE, messageUpdateHandler);
		}
		
		/**
		 * Called when new messages are available.
		 */
		private function messageUpdateHandler(event:DataManagerEvent):void {
			if(_container.contains(_spin)) _container.removeChild(_spin);
			_container.addChild(_scrollpane);
			
			//Clear previous entries
			_scrollable.content.graphics.clear();
			while(_scrollable.content.numChildren > 0) {
				_scrollable.content.getChildAt(0).filters = [];
				_scrollable.content.removeChildAt(0);
			}
			
			var i:int, len:int, items:Vector.<Message>, py:int, tf:CssTextField, label:String, censored:Boolean;
			items = event.items;
			len = items.length;
			_reportToId = new Dictionary();
			
			for(i = 0; i < len; ++i) {
				censored = items[i].reports >= Config.getNumVariable("minReportModerated");
				
				//Create title
				tf = _scrollable.addChild(new CssTextField("menuContentMessageInfos")) as CssTextField;
				tf.border = true;
				tf.borderColor = 0;
				tf.background = true;
				tf.backgroundColor = _COLORS[items[i].love];
				if(items[i].love == _COLORS.length -1) {
					tf.borderColor = 0xcc0000;
					tf.backgroundColor = 0;
				}
				tf.width = _WIDTH - _scroller.width - 5;
				tf.x = 2;
				tf.y = py;
				label = Label.getLabel("menuMessageEntryTitle");
				label = label.replace(/\$\{PSEUDO\}/gi, "<a href='"+Config.getPath("profileURL").replace(/\$\{UID\}/gi, items[i].uid)+"' target='_blank'>"+items[i].pseudo+"</a>");
				label = label.replace(/\$\{DATE\}/gi, DateUtils.format(items[i].date, DateUtils.DATE+"/"+DateUtils.MONTH+"/"+DateUtils.YEAR+" "+DateUtils.HOUR+":"+DateUtils.MINUTE));
				tf.text = label;
				py += tf.height;
				
				//Create report button
				if(items[i].reporters.search(new RegExp(","+SharedObjectManager.getInstance().uid+",", "g")) == -1 && !censored) {
					var report:BaseButton = _scrollable.addChild(new BaseButton(Label.getLabel("messageReport"), "menuContentReport", null, new WarningIconGraphic())) as BaseButton;
					_reportToId[report] = items[i].id;
					report.textBoundsMode = false;
					report.addEventListener(MouseEvent.CLICK, reportMessageHandler);
					report.x = Math.round(tf.x + tf.width - report.width - 5);
					report.y = Math.round(tf.y + (tf.height - report.height) * .5) - 1;
					report.filters = [new DropShadowFilter(2,135,0,.25,2,2,1,2)];
					report.accept(new CssVisitor());
				}
				
				tf = _scrollable.addChild(new CssTextField("menuContentMessageText")) as CssTextField;
				tf.border = true;
				tf.borderColor = 0;
				tf.background = true;
				tf.backgroundColor = 0x724338;
				if(items[i].love == _COLORS.length -1) {
					tf.borderColor = 0xcc0000;
					tf.backgroundColor = 0x8d1d1d;
				}
				tf.width = _WIDTH - _scroller.width - 5;
				tf.x = 2;
				tf.y = py;
				tf.text = censored? Label.getLabel("messageCensored") : items[i].message;
				tf.filters = [new DropShadowFilter(4, 90, 0, .25, 2, 2, .5, 2)];
				
				py += tf.height + 10;
				
//				if(i < len - 1) {
//					_scrollable.content.graphics.beginFill(0xac8b82, 1);
//					_scrollable.content.graphics.drawRect(0, py, tf.width, 1);
//					_scrollable.content.graphics.beginFill(0x160e0c, 1);
//					_scrollable.content.graphics.drawRect(0, py + 1, tf.width, 1);
//				}
				
				py += 10;
			}
			
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		override protected function computePositions():void {
			if(stage == null) return;
			
			_scrollpane.x = 1;
			_scrollpane.y = Math.round(_title.y + _title.height);
			_scrollpane.width = _WIDTH - 2;
			_scrollpane.height = Math.min(_scrollable.content.height + 1, stage.stageHeight * .25);
			_scrollpane.validate();
			
			_scrollpane.graphics.clear();
			_scrollpane.graphics.lineStyle(0, 0xffffff, 1);
			_scrollpane.graphics.beginFill(0xffffff, .05);
			_scrollpane.graphics.drawRect(-1, -1, _scrollpane.width + 1, _scrollpane.height + 1);
			_scrollpane.graphics.endFill();
			
			if(_scrollable.content.numChildren == 0) {
				_form.y = Math.round(_spin. y + _spin.height);
			}else{
				_form.y = _scrollpane.y + _scrollpane.height + 25;
			}
			
			super.computePositions();
			
			//Redraw manually due to scrollpane sizes...
			_back.graphics.clear();
			_back.graphics.lineStyle(0, 0x271714, 1);
			_back.graphics.beginFill(0x412720, 1);
			_back.graphics.drawRect(0, 0, Math.round(_scrollpane.x + _scrollpane.width + _margin*2) - 1, Math.round(_form.y + _form.height  + _margin*2) - 1);
			_back.graphics.endFill();
		}
		
		/**
		 * Called when report button is clicked.
		 */
		private function reportMessageHandler(event:MouseEvent):void {
			if(!GraphicButton(event.currentTarget).enabled) return;
			
			var id:Number = _reportToId[event.currentTarget];
			GraphicButton(event.currentTarget).visible = false;
			GraphicButton(event.currentTarget).enabled = false;
			DataManager.getInstance().reportMessage(id);
		}
		
	}
}