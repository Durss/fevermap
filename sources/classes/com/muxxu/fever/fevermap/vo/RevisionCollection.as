package com.muxxu.fever.fevermap.vo {
	import com.nurun.structure.mvc.vo.ValueObjectElement;
	import com.nurun.core.collection.Collection;
	import com.nurun.core.lang.vo.XMLValueObject;
	
	/**
	 * 
	 * @author Francois
	 * @date 8 oct. 2011
	 */
	public class RevisionCollection extends ValueObjectElement implements XMLValueObject, Collection {
		
		private var _collection:Vector.<Revision>;
		private var _isPrevPage:Boolean;
		private var _isNextPage:Boolean;
		private var _offset:Number;
		private var _total:Number;

		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>RevisionsCollection</code>.
		 */
		public function RevisionCollection() { }

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get length():uint {
			return _collection!=null? _collection.length : 0;
		}

		public function get isPrevPage():Boolean {
			return _isPrevPage;
		}

		public function get isNextPage():Boolean {
			return _isNextPage;
		}

		public function get offset():Number {
			return _offset;
		}

		public function get total():Number {
			return _total;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		public function populate(xml:XML, ...optionnals:Array):void {
			var i:int, len:int, nodes:XMLList;
			_isPrevPage = xml.child("result").@prev == "true";
			_isNextPage = xml.child("result").@next == "true";
			_offset = parseInt(xml.child("result").@offset);
			_total = parseInt(xml.child("result").@total);
			nodes = xml.child("items").child("item");
			len = nodes.length();
			_collection = new Vector.<Revision>(len, true);
			for(i = 0; i < len; ++i) {
				_collection[i] = new Revision();
				_collection[i].populate(nodes[i]);
			}
		}
		
		/**
		 * Gets an item at a specific index.
		 */
		public function getRevisionAtIndex(index:int):Revision {
			return _collection[index];
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}