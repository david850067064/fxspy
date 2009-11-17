package com.flexspy.parser.util
{
	public class NumberUtil
	{
		function NumberUtil(){  
              throw new Error("NumberUtil class is static container only");  
        }  
          
		public static function isNumeric(string:String):Boolean
		{
		   return !isNaN( Number(string) );
		}
	}
}