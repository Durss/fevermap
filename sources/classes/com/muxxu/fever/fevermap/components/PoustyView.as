package com.muxxu.fever.fevermap.components {
	import gs.TweenLite;
	import gs.TweenMax;
	import gs.easing.Bounce;
	import gs.easing.Linear;

	import com.muxxu.fever.graphics.EasterEggAerynLetterGraphic;
	import com.muxxu.fever.graphics.HeartGraphic;
	import com.muxxu.fever.graphics.PoustyHappyGraphic;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	
	/**
	 * 
	 * @author Francois
	 */
	public class PoustyView extends Sprite {
		private var _pousty:PoustyHappyGraphic;
		private var _holder:Sprite;
		private var _ks:KeyboardSequenceDetector;
		private var _konamiMode:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PoustyView</code>.
		 */
		public function PoustyView() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_holder = new Sprite();
			_pousty = _holder.addChild(new PoustyHappyGraphic()) as PoustyHappyGraphic;
			
			_pousty.scaleX = _pousty.scaleY = 5;
			
			_holder.filters = [new DropShadowFilter(0,0,0,.8,10,10,1,2)];
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(Event.RESIZE, computePositions);
			
			_ks = new KeyboardSequenceDetector(stage);
			_ks.addSequence("konami", KeyboardSequenceDetector.KONAMI_CODE);
			_ks.addSequence("aeryn", "aerynsun");
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, keyboardSequenceHandler);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(contains(_holder)) {
				while(_holder.numChildren > 0) { _holder.removeChildAt(0); }
				_holder.addChild(_pousty);
				removeChild(_holder);
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * Called when a keyboard sequence is detected
		 */
		private function keyboardSequenceHandler(event:KeyboardSequenceEvent):void {
			if(event.sequenceId == "konami") {
				TweenLite.killTweensOf(_pousty);
				_pousty.alpha = 1;
				_konamiMode = true;
				addChild(_holder);
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				enterFrameHandler();
				computePositions();
			}else{
				_konamiMode = false;
				addChild(_holder);
				aerynEasterEgg();
			}
		}
		
		/**
		 * Called on ENTER_FRAME event to add cute hearts.
		 */
		private function enterFrameHandler(event:Event = null):void {
			if(Math.random() > .8 || event == null) {
				var i:int, len:int, heart:HeartGraphic, endx:int;
				len = 5;
				for(i = 0; i < len; ++i) {
					heart = _holder.addChildAt(new HeartGraphic(), 0) as HeartGraphic;
					heart.scaleX = heart.scaleY = 2;
					heart.x = _pousty.x + (_pousty.width - heart.width) * .5;
					heart.y = _pousty.y;
					endx = MathUtils.randomNumberFromRange(-300, 300);
					TweenMax.to(heart, .7, {bezierThrough:[{x:heart.x + endx * .3, y:heart.y-Math.random() * 200}, {x:heart.x + endx, y:heart.y + 200}], ease:Linear.easeIn, removeChild:true});
				}
			}
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(_konamiMode) {
				_pousty.y = _pousty.x = 0;
				_holder.x = Math.round((stage.stageWidth - _pousty.width) * .5);
			}else{
				_holder.x = Math.round((stage.stageWidth - _pousty.x*2 - _pousty.width) * .5);
			}
			_holder.y = stage.stageHeight - _pousty.y - _pousty.height * 2;
		}
		
		/**
		 * Aerynsun's easter egg
		 */
		private function aerynEasterEgg():void {
			var text:String = "#pour aerynsun#hip! hip! hip!#hourra!!!";
			var i:int, len:int, line:Sprite, lines:Array, letter:EasterEggAerynLetterGraphic, px:int, py:int;
			len = text.length;
			lines = [];
			for(i = 0; i < len; ++i) {
				if(text.charAt(i) == "#") {
					line = _holder.addChild(new Sprite()) as Sprite;
					lines.push(line);
					line.y = py;
					py += 65;
					px = 0;
				}else if(text.charAt(i) == " ") {
					px += 44;
				}else {
					letter = new EasterEggAerynLetterGraphic();
					letter.x = px;
					letter.gotoAndStop(text.charAt(i));
					px += 44;
					line.addChild(letter);
					TweenLite.from(letter, .5, {y:"-20", alpha:0, ease:Bounce.easeOut, delay:i*.05 + (py-50)/100});
				}
			}
			
			TweenLite.from(_pousty, .25, {alpha:0, delay:(i-4)*.05 + (py-50)/100, onStart:startHearts});
			lines.push(_pousty);
			PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, lines);
			_pousty.y = line.y + line.height + 10;
			computePositions();
		}

		private function startHearts():void {
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}
}