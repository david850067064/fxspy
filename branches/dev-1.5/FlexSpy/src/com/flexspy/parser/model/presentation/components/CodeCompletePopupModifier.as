package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.IASParser;
	import com.flexspy.parser.model.domain.CodeCompleter;
	
	import mx.utils.StringUtil;

	public class CodeCompletePopupModifier
	{
		[Bindable] public var codeCompleter : CodeCompleter;
		
		public function get active() : Boolean
		{
			return codeCompleter == null ? false : codeCompleter.active;
		}
		
		public function CodeCompletePopupModifier( parser : IASParser ) 
		{
			codeCompleter = new CodeCompleter( parser );
		}

		/* TODO - handle up down and select keys in here */		

		public function startCodeCompletion( s : String ) : Boolean
		{
			/* check to see if we have a code complete popup window */
		
			codeCompleter.start( getCodeCompleteSubstring( s ) );
			return codeCompleter.active;
		}
		  
		public function updateCodeCompletion( s : String ) : Boolean
		{
			codeCompleter.updateCodeComplete( getCodeCompleteSubstring( s ) );
			return codeCompleter.active; 
		} 
		
		public function endCodeComplete( event : Event = null ) : void
		{
			codeCompleter.reset();
		}
		
		
		private function getCodeCompleteSubstring( s : String ) : String
		{
		   var resetCodeCompletionCharacter : String = "=";
		   var equalsIndex  : int = s.indexOf( resetCodeCompletionCharacter );
		   if ( equalsIndex == -1 )
		   {
		   		resetCodeCompletionCharacter = "("
		   		equalsIndex = s.indexOf( resetCodeCompletionCharacter );
		   }
			if( equalsIndex != -1 )
			{
				s = StringUtil.trim( s.substr( equalsIndex + 1 , s.length - ( equalsIndex + 1 )  ) );
			} 
			return s;
		}
	}
}