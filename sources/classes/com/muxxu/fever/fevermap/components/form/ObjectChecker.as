package com.muxxu.fever.fevermap.components.form {	import flash.geom.Matrix;
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
		/**	 * 	 * @author Francois	 * @date 14 nov. 2010;	 */
	public class ObjectChecker extends ToggleButton {

		private static const _SIZE:int = 16;
				private var _objectId:int;						


		/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ObjectChecker</code>.		 */
		public function ObjectChecker(objectId:int, scale:Number = 1.5) {
			_objectId = objectId;			var size:Number = _SIZE * scale;			var clazz:Class = getDefinitionByName("com.muxxu.fever.graphics.Item" + _objectId + "Graphic") as Class;			var back:Shape = new Shape();			back.graphics.beginFill(0xff0000, 0);
			back.graphics.drawRect(0, 0, size, size);
			back.graphics.endFill();						var icon:DisplayObject = new clazz() as DisplayObject;			var bmd:BitmapData = new BitmapData(size, size, true, 0);
			var m:Matrix = new Matrix();
			var s:Number = Math.min((_SIZE - 1) / icon.width, (_SIZE - 1) / icon.height);			m.scale(s, s);			m.translate((size - icon.width * s) * .5, (size - icon.height * s) * .5);			bmd.draw(icon, m);
						var offsetX:int = Math.max(0, (size - bmd.width)*.5);			var offsetY:int = Math.max(0, (size - bmd.height)*.5);			m = new Matrix();			m.translate(offsetX, offsetY);			back.graphics.endFill();
			back.graphics.beginBitmapFill(bmd, m);			back.graphics.drawRect(offsetX, offsetY, Math.min(size, bmd.width), Math.min(size, bmd.height));			
			super("", "", "", back, back, new ObjectCheckGraphic(), new ObjectCheckSelectedGraphic());			var fv:FrameVisitor = new FrameVisitor();			var opts:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "disabled");			fv.addTarget(defaultIcon as MovieClip, opts);
			fv.addTarget(selectedIcon as MovieClip, opts);			defaultIcon.scaleX = defaultIcon.scaleY = scale;			selectedIcon.scaleX = selectedIcon.scaleY = scale;
			accept(fv);			iconAlign = IconAlign.CENTER;
			width = height = size;						alpha = .4;
		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the object's ID.		 */		public function get objectId():int { return _objectId; }		/**		 * @inheritDoc		 */		override public function set selected(value:Boolean):void {			super.selected = value;			alpha = value? 1 : .4;		}		/* ****** *		 * PUBLIC *		 * ****** */		/**		 * @inheritDoc		 */		override public function select():void {			super.select();			alpha = 1;		}		/**		 * @inheritDoc		 */		override public function unSelect():void {			super.unSelect();			alpha = .4;		}						/* ******* *		 * PRIVATE *		 * ******* */			}}