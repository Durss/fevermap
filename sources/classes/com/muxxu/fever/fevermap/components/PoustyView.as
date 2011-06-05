package com.muxxu.fever.fevermap.components {
	import flash.filters.DropShadowFilter;
	import gs.easing.Linear;
	import com.nurun.utils.math.MathUtils;
	import gs.TweenMax;

	import com.muxxu.fever.graphics.HeartGraphic;
	import com.muxxu.fever.graphics.PoustyHappyGraphic;
	import com.nurun.utils.input.keyboard.KeyboardSequenceDetector;
	import com.nurun.utils.input.keyboard.events.KeyboardSequenceEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	/**
	 * 
	 * @author Francois
	 */
	public class PoustyView extends Sprite {
		private var _pousty:PoustyHappyGraphic;
		private var _holder:Sprite;
		private var _ks:KeyboardSequenceDetector;
		
		
		
		
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
			_ks.addEventListener(KeyboardSequenceEvent.SEQUENCE, keyboardSequenceHandler);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			computePositions();
		}
		
		/**
		 * Called when a key is pressed
		 */
		private function keyDownHandler(event:KeyboardEvent):void {
			if(contains(_holder)) {
				removeChild(_holder);
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * Called when a keyboard sequence is detected
		 */
		private function keyboardSequenceHandler(event:KeyboardSequenceEvent):void {
			addChild(_holder);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			enterFrameHandler();
			computePositions();
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
					heart.x = (_pousty.width - heart.width) * .5;
					endx = MathUtils.randomNumberFromRange(-300, 300) + heart.x;
					TweenMax.to(heart, .7, {bezierThrough:[{x:endx * .3, y:-Math.random() * 200}, {x:endx, y:200}], ease:Linear.easeIn, removeChild:true});
				}
			}
		}
		
		/**
		 * Resize and replace the elements.
		 */
		private function computePositions(event:Event = null):void {
			_holder.x = Math.round((stage.stageWidth - _pousty.width) * .5);
			_holder.y = stage.stageHeight - _pousty.height * 2;
		}
		
	}
}