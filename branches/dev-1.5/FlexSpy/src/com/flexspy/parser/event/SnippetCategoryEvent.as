package com.flexspy.parser.event
{
	import com.flexspy.parser.model.domain.SnippetCategory;
	
	import flash.events.Event;

	public class SnippetCategoryEvent extends Event
	{
		public static const SNIPPET_CATEGORY_ADDED : String = "SnippetCategoryAdded";
		
		public var category : SnippetCategory;
			
		public function SnippetCategoryEvent( type : String )
		{
			super( type  );
		}
	}
}