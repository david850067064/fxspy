package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.ASParser;
	import com.flexspy.parser.model.FTConstants;
	import com.flexspy.parser.model.HistoryManager;
	import com.flexspy.parser.model.IASParser;
	import com.flexspy.parser.view.components.CodeConsole;
	
	import flash.events.TextEvent;

	[Event("ConsoleCleared")]
	public class CodeConsoleModifier
	{
		
		public static const STATE_BIG_ENTRY : String = "BigEntry";
		
		[Bindable] public var historyManager : HistoryManager;
		[Bindable] public var parser : IASParser;
		[Bindable] public var outputText : String = FTConstants.WELCOME_MESSAGE;
		[Bindable] public var currentState : String = "";
		
		public function CodeConsoleModifier( parser : IASParser, historyManager : HistoryManager )
		{
			this.parser = parser;
			this.historyManager = historyManager;
			
			parser.addEventListener( ASParser.OUTPUT_CLEARED, handleClearText );
			parser.addEventListener( ASParser.OUTPUT_TEXT, handleOutputText );


		}

		public function processTextCommand( commandString : String ) : void
		{
			
			//split the code into commands if it contains carraige returns
			var commands : Array = commandString.split(String.fromCharCode(13));
			for (var i : int = 0; i < commands.length ; i ++ )
			{
				if ( !String(commands[i]).replace(" ", "") == "" )
				{
					parser.processString( commands[i] );
					String(commands[i]).replace(String.fromCharCode(13), "") 
				}

			}
			historyManager.addToHistory( commandString );
					
			clearConsole();
		}

		
		public function toggleInputSize() : void
		{
			currentState = (currentState == "" ) ? STATE_BIG_ENTRY : "";
		}
		
		public function clearHistory() : void
		{
			historyManager.clear();
		}
		
		public function handleOutputText( event : TextEvent ) : void 
		{
			
			outputText += formatTextForOutput( event.text );
		}
		
		public function handleClearText( event : TextEvent = null ) : void 
		{
			outputText = "";
		}
		
		public function moveHistoryUp () : void
		{
			historyManager.moveHistory( -1 );
		}
		
		public function moveHistoryDown() : void
		{
			historyManager.moveHistory( 1 );
		}
		
		private function clearConsole() : void
		{
			dispatchEvent ( new Event( CodeConsole.CONSOLE_CLEARED ) ) ;
		}
		
		private function formatTextForOutput( s : String ) : String
		{
			var returnString : String = "";
			var a : Array = s.split("\n");
			var textClassName : String;
			for each (var line : String in a )
			{
				returnString +="\n";
				if ( line.indexOf( FTConstants.OUTPUT_COMMAND )==0 )
				{
					textClassName = "command";
				} else if ( line.indexOf( FTConstants.OUTPUT_INFO )==0 )
				{ 
					textClassName = "info";
				} else if ( line.indexOf( FTConstants.OUTPUT_ERROR )==0 )
				{
					textClassName = "error";
				} else
				{
					textClassName = "normal";
				}
				
				returnString += "<span class=\"" + textClassName + "\">" + line +"</span>";
			}
			return returnString;
		}
	}
}