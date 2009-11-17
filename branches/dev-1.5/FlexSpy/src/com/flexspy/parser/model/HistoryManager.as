package com.flexspy.parser.model
{
	import mx.collections.ArrayCollection;
	import flash.net.SharedObject;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	
	[Event(name="HistoryMoved", type="flash.events.TextEvent")]
	public class HistoryManager extends EventDispatcher
	{
		public static const HISTORY_MOVED : String = "HistoryMoved";
		private var historySO : SharedObject;
		private var history : Array = [];
		private var historyPointer : int;
		
		public function HistoryManager( soName : String ="flexTramp" )
		{
			historySO = SharedObject.getLocal( soName );
			history = historySO.data.history as Array;
			if (history == null ) history = new Array();
			historyPointer = history.length;
		}
		
		public function addToHistory ( s : String ) : void
		{
			if (history.length ==0 || (history.length >0 && history[history.length-1] != s) )
			{
				history.push( s );
				if (history.length > 100) history.shift();
				historyPointer = history.length;
				historySO.data.history = history;

			}
		}
		
		public function moveHistory( direction : int ) : void
		{
			historyPointer += direction;
			if (historyPointer < 0 ) historyPointer = 0;
			if (historyPointer > history.length ) historyPointer = history.length;
			var e : TextEvent = new TextEvent(HISTORY_MOVED);
			e.text = history[ historyPointer ] as String;
			dispatchEvent( e );
		}
		
		public function getCurrentIndex() : int
		{
			return historyPointer;	
		}
		
		public function clear() : void
		{
			history=[];
			historySO.data.history = history;
			historyPointer =0;
		}

	}
}