package com.muxxu.fever.fevermap.components {

	import com.nurun.core.lang.Disposable;
	import gs.TweenLite;
	import gs.easing.Back;

	import com.muxxu.fever.graphics.InsertBackgroundGraphic;
	import com.muxxu.fever.graphics.MtHeartIconGraphic;
	import com.muxxu.fever.graphics.MtLogoGraphic;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.text.TextBounds;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * @author Francois
	 * @date 12 janv. 2011;
	 */
	public class ThanksInsert extends Sprite implements Disposable{

		private const _ENEMIES_LINES:int = 20;
		
		private var _textfield:CssTextField;
		private var _background:InsertBackgroundGraphic;
		private var _logo:Bitmap;
		private var _enemies:Vector.<DisplayObject>;
		private var _enemiesCtn:Sprite;
		private var _heart:MtHeartIconGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ThanksInsert</code>.
		 */
		public function ThanksInsert() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _background.width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _background.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			TweenLite.killTweensOf(_heart);
			while(_enemiesCtn.numChildren > 0) {
				TweenLite.killTweensOf(_enemiesCtn.getChildAt(0));
				if(_enemiesCtn.getChildAt(0) is Disposable) Disposable(_enemiesCtn.getChildAt(0)).dispose();
				_enemiesCtn.removeChildAt(0);
			}
			while(numChildren > 0) {
				if(getChildAt(0) is Disposable) Disposable(getChildAt(0)).dispose();
				removeChildAt(0);
			}
			
			filters = [];
			_enemies = null;
			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_background.removeEventListener(MouseEvent.CLICK, clickHandler);
			_background.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_background.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_enemiesCtn	= addChild(new Sprite()) as Sprite;
			_background	= addChild(new InsertBackgroundGraphic()) as InsertBackgroundGraphic;
			_textfield	= addChild(new CssTextField("thanksInsert")) as CssTextField;
			_logo		= addChild(new Bitmap(new MtLogoGraphic(NaN, NaN))) as Bitmap;
			
			var i:int, len:int, enemy:DisplayObject, clazz:Class;
			len = .5 * _ENEMIES_LINES * (_ENEMIES_LINES + 1);
			_enemies = new Vector.<DisplayObject>(len, true);
			for(i = 0; i < len; ++i) {
				clazz = getDefinitionByName("com.muxxu.fever.graphics.Enemy"+(i%3 + 1)+"Graphic") as Class;
//				clazz = getDefinitionByName("com.muxxu.fever.graphics.Enemy"+MathUtils.randomNumberFromRange(1, 3)+"Graphic") as Class;
				enemy = _enemiesCtn.addChildAt(new clazz(), 0);
				enemy.visible = false;
				_enemies[i] = enemy;
			}
			_heart = _enemiesCtn.addChild(new MtHeartIconGraphic()) as MtHeartIconGraphic;
			_heart.alpha = 0;
			_heart.visible = false;
			rollOverHandler();
			
			_textfield.text = Label.getLabel("thanks");
			_textfield.mouseEnabled = false;
			_enemiesCtn.mouseEnabled = false;
			_enemiesCtn.mouseChildren = false;
			_background.buttonMode = true;
			filters = [new DropShadowFilter(4,-135,0,.5,5,5,1,3)];
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_background.addEventListener(MouseEvent.CLICK, clickHandler);
			_background.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_background.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		/**
		 * Called when the component is rolled over.
		 */
		private function rollOverHandler(event:MouseEvent = null):void {
			var i:int, len:int, px:int, py:int, w:int, h:int, inc:int, cols:int;
			len = _enemies.length;
			w = 12;
			h = 9;
			px = 0;
			py = -12;
			inc = 0;
			cols = _ENEMIES_LINES;
			for(i = 0; i < len; ++i) {
				if(event == null) {
					_enemies[i].x = px;
					_enemies[i].y = 5;
				}else{
					_enemies[i].visible = true;
					TweenLite.to(_enemies[i], .2, {overwrite:1, x:px, y:py, delay:i*.0025, ease:Back.easeOut, easeParams:[4]});
				}
				px += w;
				inc = (inc + 1) % cols;
				if(inc == 0) {
					cols --;
					py -= h;
					px = (_ENEMIES_LINES-cols) * w * .5;
				}
			}
			
			_heart.y = Math.round(py - _heart.height + 5);
			_heart.x = Math.round(px - _heart.width * .5 + 2);
			if(event != null) {
				TweenLite.to(_heart, .25, {overwrite:1, autoAlpha:1, delay:i*.0025+.1});
			}
		}

		/**
		 * Called when the component is rolled out.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			var i:int, len:int;
			len = _enemies.length;
			for(i = 0; i < len; ++i) {
				TweenLite.to(_enemies[i], .2, {overwrite:1, y:5, delay:(len-i)*.0025, ease:Back.easeIn, easeParams:[4]});
			}
			TweenLite.to(_heart, .25, {overwrite:1, autoAlpha:0});
		}
		
		/**
		 * Called when the component is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.motion-twin.com"), "_blank");
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
			var bounds:Rectangle = TextBounds.getBounds(_textfield);
			_textfield.x = 25;
			_textfield.y = Math.round((_background.height - bounds.height) * .5 - bounds.y);
			
			_logo.x = Math.round(_textfield.x + bounds.width + 5);
			_logo.y = Math.round((_background.height - _logo.height) * .5);
			
			_background.width = Math.round(_logo.x + _logo.width + 5);
			
			_enemiesCtn.x = Math.round((_background.width - _enemiesCtn.width) * .5);
		}
		
	}
}