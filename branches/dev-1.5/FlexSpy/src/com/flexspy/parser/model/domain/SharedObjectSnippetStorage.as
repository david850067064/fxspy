package com.flexspy.parser.model.domain
{
	import com.flexspy.parser.event.SnippetStoreEvent;
	import com.flexspy.parser.model.FTConstants;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

	public class SharedObjectSnippetStorage extends EventDispatcher implements ISnippetStore  {
		
		public function retrieveSnippets() : void
		{
			var sharedObjectData : Object = getSharedObject().data.snippets;
			
			var topLevelCategory : SnippetCategory = 
					SnippetCategory( sharedObjectData );
					
			var event : SnippetStoreEvent = new SnippetStoreEvent( 
					SnippetStoreEvent.SNIPPETS_AVAILABLE );
				
			event.rootCategory = topLevelCategory;
			
			dispatchEvent( event );
		}
		
		public function storeSnippets( rootCategory : SnippetCategory ) : void
		{
			var sharedObject : SharedObject = getSharedObject();
			sharedObject.data.snippets = rootCategory;
			
			sharedObject.flush();
		}
		
		private function getSharedObject() : SharedObject
		{
			return SharedObject.getLocal( FTConstants.SO_PATH );
		}
	}
}