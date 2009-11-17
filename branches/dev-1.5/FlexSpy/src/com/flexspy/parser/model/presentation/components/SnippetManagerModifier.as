package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.domain.Snippet;
	import com.flexspy.parser.model.domain.SnippetCategory;
	import com.flexspy.parser.model.domain.Snippets;
	
	import mx.collections.ArrayCollection;
	
	public class SnippetManagerModifier
	{
		[Bindable]
		public var snippetsRoot : ArrayCollection;
		
		public function SnippetManagerModifier( snippets : Snippets )
		{
			snippetsRoot = new ArrayCollection( [ snippets.rootCategory ] ); 
		}
		
		public function getAsToolTip( item : Object ) : String
		{
			var tip : String;
			
			if( item is Snippet )
			{
				tip = Snippet( item ).description;
			}
			else if( item is SnippetCategory )
			{
				tip = SnippetCategory( item ).name;
			}
			else
			{
				tip = "";	
			}

			return tip;	
		}
	}
}