package com.flexspy.parser.model.domain
{
	import com.flexspy.parser.model.FTConstants;
	
	[RemoteClass(alias="com.flexspy.parser.model.domain.Snippet")]
	public class Snippet
	{
		public var name : String;
		public var description : String;
		public var code : String;
		
		//this aint very OO, maybe do as part of snippet constructor
		public static function parseCodeFromText( text : String ) : String
		{
			var code : String = "";
			var lines : Array = text.split( "\r");
			
			for each( var line : String in lines )
			{
				if( line.indexOf( FTConstants.OUTPUT_COMMAND ) == 0 )
				{
					code += line.substring( FTConstants.OUTPUT_COMMAND.length ) + "\n";
				}
			}
			
			return code;			
		}
				
	}
}