package com.muxxu.fever.fevermap.components.form {

	import com.muxxu.fever.fevermap.vo.RevisionCollection;
	import com.nurun.utils.date.DateUtils;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.components.button.AbstractNurunButton;
	import com.muxxu.fever.fevermap.components.button.FeverButton;
	import com.muxxu.fever.fevermap.data.DataManager;
	import com.muxxu.fever.fevermap.events.DataManagerEvent;
	import com.muxxu.fever.fevermap.vo.Revision;
	import com.muxxu.fever.graphics.ArrowNextGraphic;
	import com.muxxu.fever.graphics.ArrowPrevGraphic;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.math.MathUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	/**
	 * 
	 * @author Francois
	 * @date 21 nov. 2010;
	 */
	public class RevisionsPaginator extends Sprite {
		
		private const _WIDTH:int = 300;
		private const _CONTENT_HEIGHT:int = 60;
		
		private var _index:int;
		private var _prevBt:FeverButton;
		private var _nextBt:FeverButton;
		private var _infos:CssTextField;
		private var _title:CssTextField;
		private var _revisions:RevisionCollection;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>RevisionsPaginator</code>.
		 */
		public function RevisionsPaginator() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the current revision
		 */
		public function get revision():Revision { return _revisions.getRevisionAtIndex(_index); }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(revisions:RevisionCollection):void {
			_index = 0;
			_revisions = revisions;
			updateState();
		}
		

		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_title	= addChild(new CssTextField("revisionTitle")) as CssTextField;
			_infos	= addChild(new CssTextField("revisionInfos")) as CssTextField;
			_prevBt	= addChild(new FeverButton("", new ArrowPrevGraphic())) as FeverButton;
			_nextBt	= addChild(new FeverButton("", new ArrowNextGraphic())) as FeverButton;
			
			_nextBt.iconAlign = IconAlign.RIGHT;
			_nextBt.textAlign = TextAlign.LEFT;
			_title.text = Label.getLabel("revisionsTitle");
			_title.background = true;
			_title.backgroundColor = 0;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_COMPLETE, loadRevisionsCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.LOAD_REVISIONS_ERROR, loadRevisionsErrorHandler);
			
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Called when a button is clicked.
		 */
		private function clickHandler(event:MouseEvent):void {
			if(!(event.target is AbstractNurunButton)) return;
			
			if(event.target == _prevBt) _index++;
			if(event.target == _nextBt) _index--;
			_index = MathUtils.restrict(_index, 0, _revisions.length);
			updateState();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			graphics.clear();
			
			_nextBt.validate();
			_prevBt.validate();
			
			_title.width = _WIDTH;
			_infos.y = Math.round(_title.height);
			
			_prevBt.x = 2;
			_prevBt.y = _nextBt.y = Math.round(_infos.y + _CONTENT_HEIGHT - _prevBt.height - 2);
			_nextBt.x = Math.round(_WIDTH - _nextBt.width - 2);
			
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, _WIDTH, _nextBt.y + _nextBt.height + 4);
			graphics.endFill();
			
			graphics.beginFill(0xffffff, .15);
			graphics.drawRect(0, _infos.y, _WIDTH, _CONTENT_HEIGHT);
			graphics.endFill();
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Updates the buttons state
		 */
		private function updateState():void {
			if(_revisions == null || _revisions.length == 0) {
				while(numChildren > 0) { removeChildAt(0); }
				alpha = .5;
				addChild(_title);
				addChild(_infos);
				_infos.text = Label.getLabel("revisionsEmpty");
				computePositions();
				return;
			}
			
			alpha = 1;
			addChild(_title);
			addChild(_infos);

			var revision:Revision = _revisions.getRevisionAtIndex(_index);
			
			var title:String = Label.getLabel("revisionsInfos");
			title = title.replace(/\$\{nbr\}/gi, _revisions.length - _index);
			title = title.replace(/\$\{tot\}/gi, _revisions.length);
			title = title.replace(/\$\{user\}/gi, revision.pseudo);
			title = title.replace(/\$\{date\}/gi, DateUtils.format(revision.date, DateUtils.DATE+"/"+DateUtils.MONTH+"/"+DateUtils.YEAR+" "+DateUtils.HOUR+":"+DateUtils.MINUTE));
			_infos.text = title;
			
			visible = true;
			
			if(contains(_prevBt)) removeChild(_prevBt);
			if(contains(_nextBt)) removeChild(_nextBt);
			
			if(_index + 1 < _revisions.length) {
				_prevBt.label = _revisions.getRevisionAtIndex(_index + 1).pseudo;
				addChild(_prevBt);
			}
			if(_index - 1 >= 0){
				_nextBt.label = _revisions.getRevisionAtIndex(_index - 1).pseudo;
				addChild(_nextBt);
			}
			
			computePositions();
		}

		
		
		
		//__________________________________________________________ SERVER RESULTS
		
		/**
		 * Called when revisions loading completes.
		 */
		private function loadRevisionsCompleteHandler(event:DataManagerEvent):void {
			updateState();
		}

		/**
		 * Called if revisions loading fails.
		 */
		private function loadRevisionsErrorHandler(event:DataManagerEvent):void {
		}
		
	}
}