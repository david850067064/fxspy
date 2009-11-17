package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.domain.SnippetCategory;
	import com.flexspy.parser.model.domain.Snippets;
	
	public class NewSnippetCategoryModifier
	{
		private var snippets : Snippets;
		
		[Bindable]
		public var name : String;
		
		[Bindable]
		public var parent : SnippetCategory;  
		
		"ssds";
		
		public function NewSnippetCategoryModifier( snippets : Snippets )
		{
			this.snippets = snippets;	
		}
		
		public function addCategory() : SnippetCategory
		{
			var newCategory : SnippetCategory = parent.addSubCategory( name );
			
			snippets.persist();
			
			return newCategory;
		}
	}
}