package com.muxxu.fever.fevermap.components.form {
	import com.nurun.components.text.CssTextField;
	import flash.display.Sprite;
	
	public class FeverLabeledInput extends Sprite {

		private var _label:CssTextField;
		private var _input:FeverInput;
		private var _labelStr:String;
		
		public function FeverLabeledInput(label:String) {
			_labelStr = label;
			initialize();
		public function get value():String { return _input.text; }
			_input = addChild(new FeverInput()) as FeverInput;
			
			
		private function computePositions():void {
			PosUtils.hPlaceNext(10, _label, _input);
			_input.validate();
		}