package com.muxxu.fever.fevermap.components.form {

	import com.muxxu.fever.fevermap.components.scrollbar.FeverScrollBar;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.graphics.ButtonSelectSkin;
	import com.muxxu.fever.graphics.ButtonSkin;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.FrameVisitor;
	import com.nurun.components.button.visitors.FrameVisitorOptions;
	import com.nurun.components.form.ComboBox;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.form.events.ListEvent;
	import com.nurun.components.vo.Margin;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;


	/**
	 * @author Francois
	 * @date 2 déc. 2010;
	 */
	public class FeverCombobox extends ComboBox {

		private var _updateBt:Boolean;

		public function FeverCombobox(label:String = "", openToTop:Boolean = false, updateBt:Boolean = false, scroll:Boolean = false) {
			_updateBt = updateBt;
			var button:FeverButton = new FeverButton(label);
			button.style = "combobox";
			super(button, scroll? new FeverScrollBar() : null, null, null, openToTop);
		}
		
		public function addSkinnedItem(label:String, value:*, style:String="comboboxItem", icon:DisplayObject=null):ToggleButton {
			var item:ToggleButton = new ToggleButton(label, style, style, new ButtonSkin(), new ButtonSelectSkin());
			item.contentMargin = new Margin(5, 5, 5, 4);
			if(icon != null){
				item.icon = icon;
				if(label == "") {
					item.iconAlign = IconAlign.CENTER;
					item.textAlign = TextAlign.CENTER;
					FeverButton(_button).iconAlign = IconAlign.CENTER;
					FeverButton(_button).textAlign = TextAlign.CENTER;
				}
				item.contentMargin = new Margin(0, 5, 0, 4);
			}
			
			var fv:FrameVisitor = new FrameVisitor();
			var opts:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "disable");
			fv.addTarget(item.selectedBackground as MovieClip, opts);
			fv.addTarget(item.defaultBackground as MovieClip, opts);
			item.accept(fv);
			
			addItem(item, value);
			
			return item;
		}
		
		override protected function selectItemHandler(e:ListEvent):void {
			super.selectItemHandler(e);
			if(_updateBt) {
				var icon:DisplayObject = ToggleButton(_list.scrollableList.getItemAt(selectedIndex)).icon;
				var bmd:BitmapData = new BitmapData(icon.width, icon.height, true, 0);
				bmd.draw(icon);
				FeverButton(_button).icon = new Bitmap(bmd);
				FeverButton(_button).label = ToggleButton(_list.scrollableList.getItemAt(selectedIndex)).label;
			}
		}

		public function get opened():Boolean {
			return _opened;
		}
	}
}
