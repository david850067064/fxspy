package com.flexspy.parser.model
{
	import com.flexspy.parser.model.domain.Snippets;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[Exclude]
	public class FlexTrampModelLocator
	{
		public var parser : ASParser= new ASParser();
		public var historyManager : HistoryManager = new HistoryManager( FTConstants.SO_PATH );
		public var variables : ArrayCollection = parser.displayVariables;
		public var snippets : Snippets = new Snippets();
		
		private static var _instance : FlexTrampModelLocator;	

		public function FlexTrampModelLocator( enforcer : SingletonEnforcer) : void
	 	{
	 	}
		
		public static function getInstance() : FlexTrampModelLocator
		{
			if ( _instance == null)  
				_instance = new FlexTrampModelLocator( new SingletonEnforcer() );
				
			return _instance;	
		}
	}
}

class SingletonEnforcer {}