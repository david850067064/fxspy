package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.domain.Snippet;
	import com.flexspy.parser.model.domain.SnippetCategory;
	import com.flexspy.parser.model.domain.Snippets;
	
	public class AddSnippetModifier
	{
		[Bindable]
		public var code : String;
		
		[Bindable]
		public var name : String;
		
		[Bindable]
		public var description : String; 
				
		[Bindable]
		public var selectedCategory : SnippetCategory;		
		
		[Bindable]
		public var snippets : Snippets; 
		
		public function AddSnippetModifier( snippets : Snippets )
		{
			this.snippets = snippets;
		}
		
		public function add() : void
		{
			selectedCategory.addSnippet( name, description, code );
			
			//todo, make this happen automatically
			snippets.persist();			
		}
	}
}