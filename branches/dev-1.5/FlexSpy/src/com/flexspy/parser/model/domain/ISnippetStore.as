package com.flexspy.parser.model.domain
{
	import flash.events.IEventDispatcher;

	public interface ISnippetStore extends IEventDispatcher
	{
		function retrieveSnippets() : void;
		
		function storeSnippets( rootCategory : SnippetCategory ) : void;
	}
}