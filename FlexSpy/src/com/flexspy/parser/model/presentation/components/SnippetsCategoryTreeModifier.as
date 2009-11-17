package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.domain.Snippets;
	
	import mx.collections.ArrayCollection;
	
	public class SnippetsCategoryTreeModifier
	{
		[Bindable]
		public var snippetsRoot : ArrayCollection; 
		
		public function SnippetsCategoryTreeModifier( snippets : Snippets )
		{
			snippetsRoot = new ArrayCollection( [ snippets.rootCategory ] );
		}
	}
}