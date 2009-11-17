package com.flexspy.parser.event
{
	import com.flexspy.parser.model.domain.SnippetCategory;
	
	import flash.events.Event;

	public class SnippetStoreEvent extends Event
	{
		public static const SNIPPETS_AVAILABLE : String = "snippetAvailable";
		public static const SNIPPETS_PERSISTED : String = "snippetsPersisted";
		
		public var rootCategory : SnippetCategory;
		
		public function SnippetStoreEvent( type : String, 
				bubbles : Boolean = false, 
				cancelable:Boolean=false ) {
					
			super( type, bubbles, cancelable );
		}
	}
}