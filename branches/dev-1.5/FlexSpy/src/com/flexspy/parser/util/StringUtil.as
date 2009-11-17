   package com.flexspy.parser.util
   {  
       public class StringUtil
       {  
	      function StringUtil(){  
              throw new Error("StringUtil class is static container only");  
          }  
          
           //比较字符是否相等;  
           public static function equals(char1:String,char2:String):Boolean{  
              return char1 == char2;  
          }  
            
          //是否为Email地址;  
          public static function isEmail(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
            
         
            
          //是否为Double型数据;  
          public static function isDouble(char:String):Boolean{  
              char = trim(char);  
              var pattern:RegExp = /^[-\+]?\d+(\.\d+)?$/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //Integer;  
          public static function isInteger(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /^[-\+]?\d+$/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //English;  
          public static function isEnglish(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /^[A-Za-z]+$/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //中文;  
          public static function isChinese(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /^[\u0391-\uFFE5]+$/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //双字节  
          public static function isDoubleChar(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /^[^\x00-\xff]+$/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //含有中文字符  
          public static function hasChineseChar(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char);  
              var pattern:RegExp = /[^\x00-\xff]/;   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //注册字符;  
          public static function hasAccountChar(char:String,len:uint=15):Boolean{  
              if(char == null){  
                  return false;  
              }  
              if(len < 10){  
                  len = 15;  
              }  
              char = trim(char);  
              var pattern:RegExp = new RegExp("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,"+len+"}$", "");   
              var result:Object = pattern.exec(char);  
              if(result == null) {  
                  return false;  
              }  
              return true;  
          }  
          //URL地址;  
          public static function isURL(char:String):Boolean{  
              if(char == null){  
                  return false;  
              }  
              char = trim(char).toLowerCase();  
              var pattern:RegExp = /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;  
              var result:Object = pattern.exec(char); 
              if(result == null) { 
                  return false; 
              } 
              return true; 
          } 
           
          // 是否为空白;         
          public static function isWhitespace(char:String):Boolean{ 
              switch (char){ 
                  case " ": 
                  case "\t": 
                  case "\r": 
                  case "\n": 
                  case "\f": 
                      return true;     
                  default: 
                      return false; 
              } 
          } 
           
          //去左右空格; 
          public static function trim(char:String):String{ 
              if(char == null){ 
                  return null; 
              } 
              return rtrim(ltrim(char)); 
          } 
           
          //去左空格;  
          public static function ltrim(char:String):String{ 
              if(char == null){ 
                  return null; 
              } 
              var pattern:RegExp = /^\s*/;  
              return char.replace(pattern,""); 
          } 
           
          //去右空格; 
          public static function rtrim(char:String):String{ 
              if(char == null){ 
                  return null; 
              } 
              var pattern:RegExp = /\s*$/;  
              return char.replace(pattern,""); 
          } 
           
          //是否为前缀字符串; 
          public static function beginsWith(char:String, prefix:String):Boolean{             
              return (prefix == char.substring(0, prefix.length)); 
          } 
           
          //是否为后缀字符串; 
          public static function endsWith(char:String, suffix:String):Boolean{ 
              return (suffix == char.substring(char.length - suffix.length)); 
          } 
           
          //去除指定字符串; 
          public static function remove(char:String,remove:String):String{ 
              return replace(char,remove,""); 
          } 
           
          //字符串替换; 
          public static function replace(char:String, replace:String, replaceWith:String):String{             
              return char.split(replace).join(replaceWith); 
          } 

	        public static function getDifference(s : String, t : String ) : String 
	        {
	        	if (s.length > t.length )
	        		return s.substring( t.length, s.length );
	        	else
	        		return t.substring( s.length, t.length );
	        }

      }  
  }  