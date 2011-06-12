package com.muxxu.fever.fevermap.components.form {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.muxxu.fever.graphics.ObjectCheckSelectedGraphic;
	import com.muxxu.fever.graphics.ObjectCheckGraphic;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import com.nurun.components.form.ToggleButton;
	
	public class ObjectChecker extends ToggleButton {

		private static const _SIZE:int = 16;
		


		/* *********** *
		public function ObjectChecker(objectId:int, scale:Number = 1.5) {
			_objectId = objectId;
			back.graphics.drawRect(0, 0, size, size);
			back.graphics.endFill();
			var m:Matrix = new Matrix();
			var s:Number = Math.min((_SIZE - 1) / icon.width, (_SIZE - 1) / icon.height);
			
			back.graphics.beginBitmapFill(bmd, m);
			super("", "", "", back, back, new ObjectCheckGraphic(), new ObjectCheckSelectedGraphic());
			fv.addTarget(selectedIcon as MovieClip, opts);
			accept(fv);
			width = height = size;
		}