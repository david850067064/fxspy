package com.flexspy.parser.model
{
	public class FTConstants
	{
		public static const SO_PATH : String = "FlexTramp";
		public static const WELCOME_MESSAGE : String = 
			"Use this panel to execute (simple) as code.";
		
		/* tokens you might find in the parser text */
		public static const OUTPUT_INFO : String = "I:";
		public static const OUTPUT_COMMAND : String = "C:";
		public static const OUTPUT_ERROR : String = "E:";
		
		public static const codeCompleteWhiteSpace : RegExp = 
				new RegExp("(\ )","g");
		
	}
}