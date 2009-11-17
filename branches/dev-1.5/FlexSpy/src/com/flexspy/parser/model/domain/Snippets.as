package com.flexspy.parser.model.domain
{
	import com.flexspy.parser.event.SnippetCategoryEvent;
	import com.flexspy.parser.event.SnippetEvent;
	import com.flexspy.parser.event.SnippetStoreEvent;
	
	public class Snippets
	{
		[Bindable]
		public var rootCategory : SnippetCategory;
		
		private var storage : ISnippetStore;
		
		public function Snippets( storage : ISnippetStore = null )
		{
			if( !storage )
			{
				storage = new SharedObjectSnippetStorage();	
			}
			
			this.storage = storage;
			
			this.storage.addEventListener( 
					SnippetStoreEvent.SNIPPETS_AVAILABLE,
					handleSnippetsAvailable );
					
			storage.retrieveSnippets();
		}
		
		public function persist() : void
		{
			storage.storeSnippets( rootCategory );		
		}
		
		protected function handleSnippetsAvailable( event : SnippetStoreEvent ) : void
		{
			rootCategory = event.rootCategory;
			
			if( rootCategory == null )
			{
				rootCategory = createRootSnippetCategory();
				storage.storeSnippets( rootCategory );	
			}
			
			rootCategory.addEventListener( 
					SnippetCategoryEvent.SNIPPET_CATEGORY_ADDED,
					handleSnippetCategoryAdded );
					
			rootCategory.addEventListener(
					SnippetEvent.SNIPPET_ADDED,
					handleSnippetAdded ); 
		}
		
		private function handleSnippetCategoryAdded( event : SnippetCategoryEvent ) : void
		{
			storage.storeSnippets( rootCategory );
		}
		
		private function handleSnippetAdded( event : SnippetEvent ) : void
		{
			storage.storeSnippets( rootCategory );
		}
		
		private function createRootSnippetCategory() : SnippetCategory
		{
			var root : SnippetCategory = new SnippetCategory();
			root.name = SnippetCategory.ROOT;
			
			return root;
		}
	}
}