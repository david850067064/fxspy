package com.flexspy.parser.model.domain
{
	import com.flexspy.parser.event.SnippetCategoryEvent;
	import com.flexspy.parser.event.SnippetEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	
	[Event(name="SnippetCategoryAdded", type="com.flexspy.parser.event.SnippetCategoryEvent")]
	[Event(name="SnippetAdded", 		type="com.flexspy.parser.event.SnippetEvent")]
	
	[RemoteClass(alias="com.flexspy.parser.model.domain.SnippetCategory")]
	public class SnippetCategory extends EventDispatcher implements IExternalizable
	{
		public static const ROOT : String = "Snippets"; 
		
		[Bindable]
		public var name : String;
		public var parent : SnippetCategory;
		
		private var _categories : ArrayCollection;
		private var _snippets : ArrayCollection;

		public function SnippetCategory()
		{
			_categories = new ArrayCollection();
			_snippets = new ArrayCollection();
		}
		
		public function get categories() : ICollectionView
		{
			return _categories;	
		}
		
		public function get snippets() : ICollectionView
		{
			return _snippets;
		}
		
		public function getSnippetAt( index : int ) : Snippet
		{
			return Snippet( _snippets.getItemAt( index ) );
		}
		
		public function addSubCategory( name : String ) : SnippetCategory
		{
			var newCategory : SnippetCategory = new SnippetCategory();
			
			newCategory.name = name;
			newCategory.parent = this;
			
			_categories.addItem( newCategory );
			
			var event : SnippetCategoryEvent = new SnippetCategoryEvent( 
					SnippetCategoryEvent.SNIPPET_CATEGORY_ADDED );
			
			event.category = newCategory;
			
			dispatchEvent( event );
			
			return newCategory;
		}
		
		public function addSnippet( name : String, description : String, code : String ) : Snippet
		{
			var newSnippet : Snippet = new Snippet();
			
			newSnippet.code = code;
			newSnippet.description = description;
			newSnippet.name = name;
			
			_snippets.addItem( newSnippet );
			
			var event : SnippetEvent = 
					new SnippetEvent( newSnippet, SnippetEvent.SNIPPET_ADDED );
					
			dispatchEvent( event );
			
			return newSnippet;
		}
		
		public function isRoot() : Boolean
		{
			return ( name == ROOT ); 
		}
		
		public function writeExternal( output : IDataOutput ) : void
		{
			output.writeObject( name );
    		output.writeObject( _snippets );
    		output.writeObject( _categories );
		}

		public function readExternal( input : IDataInput ) : void
		{
    		name = String( input.readObject() );
	    	_snippets = ArrayCollection( input.readObject() );
    		_categories= ArrayCollection( input.readObject() );
		}

		override public function addEventListener( type : String, listener : Function, 
				useCapture : Boolean = false, priority : int = 0, 
				useWeakReference : Boolean = false ) : void {
					
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			
			for each( var subCategory : SnippetCategory in _categories )
			{
				subCategory.addEventListener( type, 
						listener, 
						useCapture, 
						priority, 
						useWeakReference ); 		
			}
		}
	}
}