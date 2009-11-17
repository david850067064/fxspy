package com.flexspy.parser.event
{
	import com.flexspy.parser.model.domain.Snippet;
	
	import flash.events.Event;

	public class SnippetEvent extends Event
	{
		public static const SNIPPET_SELECTED : String = "SnippetSelected";
		public static const SNIPPET_ADDED : String = "SnippetAdded";
		
		public var snippet : Snippet;
		
		public function SnippetEvent( snippet : Snippet, type : String )
		{
			super( type );
			
			this.snippet = snippet;
		}
	}
}