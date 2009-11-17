package com.flexspy.parser.model.presentation
{
	import com.flexspy.parser.model.ASParser;
	import com.flexspy.parser.model.FTConstants;
	import com.flexspy.parser.model.HistoryManager;
	import com.flexspy.parser.model.IASParser;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	[Event("ConsoleCleared")]
	public class FlexTrampModifier
	{

		
		public static const CONSOLE_CLEARED : String = "ConsoleCleared";
		
		[Bindable] public var historyManager : HistoryManager;
		[Bindable] public var parser : IASParser;
		[Bindable] public var outputText : String = FTConstants.WELCOME_MESSAGE;
		
		public function FlexTrampModifier( parser : IASParser, historyManager : HistoryManager )
		{
			this.historyManager = historyManager;
			this.parser = parser;
			parser.addEventListener( ASParser.OUTPUT_CLEARED, handleClearText );
			parser.addEventListener( ASParser.OUTPUT_TEXT, handleOutputText );
		}

		public function processTextCommand( commandString : String, 
				event :KeyboardEvent = null ) : void
		{
			if (event != null )
			{
				if ( !( event.keyCode == Keyboard.ENTER && !event.shiftKey ) )
				{
					if (event.keyCode == Keyboard.UP ) historyManager.moveHistory(-1);
					if (event.keyCode == Keyboard.DOWN ) historyManager.moveHistory(1);
					if (event.keyCode == Keyboard.ESCAPE ) clearConsole();
					return;
				}
			}

			//split the code into commands if it contains carraige returns
			var commands : Array = commandString.split(String.fromCharCode(13));
			for (var i : int = 0; i < commands.length ; i ++ )
			{
				if ( !String(commands[i]).replace(" ", "") == "" )
				{
					parser.processString( commands[i] );
					String(commands[i]).replace(String.fromCharCode(13), "") 
					historyManager.addToHistory( commands[i] );
					
				}

			}
			clearConsole();
		}

		public function clearHistory() : void
		{
			historyManager.clear();
		}
		
		public function handleOutputText( event : TextEvent ) : void 
		{
			outputText += event.text;
		}
		
		public function handleClearText( event : TextEvent ) : void 
		{
			outputText = "";
		}
		
		private function clearConsole() : void
		{
			dispatchEvent ( new Event( CONSOLE_CLEARED ) ) ;
		}
	}
}