package com.flexspy.parser.model 
{
	import com.flexspy.parser.util.NumberUtil;
	import com.flexspy.parser.util.StringUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	[Event("OutputCleared")]
	[Event(name="OutputText", type="flash.events.TextEvent")]
	public class ASParser extends EventDispatcher implements IASParser
	{
		public static const OUTPUT_CLEARED : String = "OutputCleared";
		public static const OUTPUT_TEXT : String = "OutputText";
		public static const VARIABLES_CHANGED : String = "variablesChanged";

		[Bindable] 
		public var displayVariables : ArrayCollection = new ArrayCollection();
		
		private var variables : Object = new Object;
		
		public function processString( s: String ) : void
		{
			var returnString : String = "\n" + FTConstants.OUTPUT_COMMAND + s;
			var varPath : Array;
			var assignment : String
			
			
			//new variable
			if (s.substr(0,3)=="cls")
			{
				dispatchEvent( new Event ( OUTPUT_CLEARED ) );
				return;
			}
			if (s.substr(0,6)=="delete")
			{
				s = s.replace("delete","");
				s = s.replace(" ","");

				deleteVar (s);
			}
			
			if (s.substr(0,3)=="var")
			{
				s = s.substr(3, s.length-3);	
			}
			var equalsIndex : int = s.indexOf("=");
			var doubleEqualsIndex : int = s.indexOf("==");
			var notEqualsIndex : int = s.indexOf("!=");
			
			if (equalsIndex != -1 && s.length > equalsIndex && doubleEqualsIndex != equalsIndex 
					&& notEqualsIndex != (equalsIndex-1))
			{
				//assignment
				varPath = getVariableFromAssignment( s);
				assignment = getAssignment( s );
				returnString += "\n" + FTConstants.OUTPUT_INFO + assignment;
				parseAssignment( varPath, assignment );
			}
			else
			{
				//method invocation
				var resultValue : Object = getRealValueOf( s );
				returnString += "\n" + FTConstants.OUTPUT_INFO;
				returnString += resultValue== null ? "null" : resultValue.toString() ;				
			}
			if ( returnString != null )
			{
				var e : TextEvent = new TextEvent( OUTPUT_TEXT );
				e.text = returnString;
				dispatchEvent( e );
			}
		}
		
		public function getVariables() : ArrayCollection
		{
			return displayVariables;
		}
		
		public function addVariable(varName : String, value : Object ) : void
		{
			if ( !displayVariables.contains( varName ) ){
				displayVariables.addItem(varName);
			}
			variables[varName] = value;
		}
		
		public function getObjectByName( objectName : String ) : Object
		{
			return getRealValueOf( objectName );
		}
		
		public function isPrimitive( s : String ) : Boolean
		{
			return parsePrimitive( s ) != "NO";
		}
		
		private function createObject( clazzName : String, clazzArgs : Array ) : Object
		{
			var _class:Class = getDefinitionByName(clazzName) as Class;
			var returnObject : Object;
			switch (clazzArgs.length)
			{
				case 0:
				returnObject = new _class();
				break;
				case 1:
				returnObject = new _class( clazzArgs[0]);
				break;
				case 2:
				returnObject = new _class(clazzArgs[0], clazzArgs[1]);
				break;
				case 3:
				returnObject = new _class(clazzArgs[0],clazzArgs[1],clazzArgs[2]);
				break;
				
			} 
			return returnObject;
		}
		
		private function doAssign(varPath : Array, value : Object ) : void
		{
			// get the value for the assignemnt!
			
			if (varPath.length==1 ) 
			{

				//local var
				var varName : String = varPath[0];
				if (variables[ varName ] != null )
				{
					displayVariables.removeItemAt( displayVariables.getItemIndex( varName ) );
					variables[ varName ] = null;
				}
				displayVariables.addItem( varName );
				variables[ varName ] = value;
				
			}
			else
			{
				//more complicated variable path
				var objectToAssign : Object = getObjectFromPath( varPath );
				objectToAssign[ varPath[varPath.length -1 ] ] = value;
			}

		}
		
		private function copyArray( source : Array) : Array
		{
		    var myBA:ByteArray = new ByteArray();
		    myBA.writeObject(source);
		    myBA.position = 0;
		    return(myBA.readObject());
		}
		private function deleteVar( s : String ) : void
		{
			if (s != "" )
			{
				var targetItem : Object = variables[ s ];
				var index : int = displayVariables.getItemIndex( s );
				if (index != -1 )
				{
					displayVariables.removeItemAt( index );
					variables[s] = null;
					
				}
			}
		}

	
		private function parsePrimitive( s :String, isAssign : Boolean= false ) : Object
		{
			s = StringUtil.ltrim( StringUtil.rtrim( s ) );

			var returnObject : Object  = "NO";
			var firstQuote : int  = s.indexOf("\"");
			if ( NumberUtil.isNumeric( s ) )
			{
				returnObject = Number (s);
			} else if (s == "true" )
			{
				returnObject = true;
			} else if (s == "false" )
			{
				returnObject = false;
			}else if (s == "null" )
			{
				returnObject = null;
			}else if (s.indexOf("[") != -1  && isAssign)
			{
				returnObject = createArray (s);
			} else if (s.substr(0,4) == "new " )
			{
				s = s.substr(4, s.length - 4);
				//strip out args
				var args : Array = parseArgs( s );
				s = s.substr(0, s.indexOf("(") );
				returnObject = createObject( s, args ) ;
			} else if ( firstQuote != -1)
			{
				if (s.substr(0, firstQuote).replace(" ", "") == "\"" || firstQuote==0)
				{
					//string value
					returnObject = s.substr(firstQuote +1 , s.lastIndexOf("\"") -1);
				}
			}
			return returnObject;
		}
		
		private function createArray ( s: String ) : Object
		{
			var arrayString : String = s.substring(s.indexOf("[") +1, s.indexOf("]") );
			var arrayObjects : Array = arrayString..split(",") ;
			for (var i : int = 0 ; i < arrayObjects.length; i++) 
			{
				arrayObjects[i] = getRealValueOf( arrayObjects[i] );	
			}
			return arrayObjects;
			
		}
		
		private function parseMethodOrAttribute ( s : String ) : Object
		{
			var result : Object = "error";
			if (s.replace(" ", "") =="" ) return null;
			s = StringUtil.ltrim( StringUtil.rtrim( s ) );
			var varPath : Array;
			var targetObject : Object; 
			
			if (s.indexOf("(") == -1  && s.indexOf("[") == -1)
			{
				varPath = s.split(".");
				targetObject = getObjectFromPath( varPath );
				if (varPath.length >1 ) {
					if ( targetObject && targetObject.hasOwnProperty( varPath[varPath.length -1] ))
					{
						result = targetObject[varPath[varPath.length -1]] ;
					}	
				} else
				{
					result =  targetObject;
				}
			}
			else if (s.indexOf("(") != -1)
			{
				var methodName : String = s.substr(0, s.indexOf("(") );
				var args : Array = parseArgs( s );
				
				varPath = methodName.split(".");
				methodName=varPath[varPath.length -1 ];
				targetObject = getObjectFromPath( varPath );
				result = doMethodCall( targetObject, methodName, args );
			}
			else if (s.indexOf("[") != -1)
			{
				var arrayIndex : int = s.indexOf("[");
				var indexString : String = s.substring(arrayIndex+1, s.lastIndexOf("]") );
				varPath = s.split(".");
				//remove square brackets from last entry in path
				var lastPath : String = varPath[varPath.length-1];
				varPath[varPath.length-1] = lastPath.substr(0, lastPath.indexOf("["));
				targetObject = getObjectFromPath( varPath );
				if ( isPrimitive(indexString) && !isNaN( parsePrimitive(indexString) as Number ) )
				{
					result = targetObject[parsePrimitive(indexString)];
				}
				else
				{
					result = targetObject[parseMethodOrAttribute( indexString )];
				}
			}
			

			return result;
		}

		private function getObjectFromPath ( varPath : Array ) : Object
		{
			var returnObject : Object = possibleClassCall(varPath );
			if ( returnObject != null ) return returnObject;
			if (varPath.length == 1)
			{
				//do a check, for vars
				returnObject = getRootObject( varPath );
			}
			else
			{
				//recurse over object, to actually work it out!
				returnObject = getRootObject( varPath );
				for (var i : int = 1; i < varPath.length-1 && returnObject !=null ; i ++  )
				{
					returnObject = returnObject[ varPath[i] ];
				}
				
			}
			return returnObject;
		}
		
		private function getRootObject( varPath : Array ) : Object
		{
			var returnObject : Object;
			returnObject = variables[varPath[0]];
			if (returnObject == null ) 
			{
				//check static object
				returnObject = doClassLookup( varPath[0] );
			}
			return returnObject;
		}
		
		private function possibleClassCall( varPath : Array ) : Object
		{
			if (varPath.length==1) 
			{ 
				return doClassLookup( varPath[0] );			
			}
			
			var pathToUse : Array = copyArray(varPath);
			pathToUse.pop();
			return doClassLookup( pathToUse.join(".") );
		}
		
		private function doClassLookup( clazzName : String ) : Object
		{
			var returnObject : Object;
			try {
				returnObject = getDefinitionByName(clazzName);
			} catch (e : Error ) {}
			return returnObject;
		
		}
		
		//s is assignment text
		private function parseAssignment( varPath : Array, s : String ) : void
		{
			var value : Object;
			var args : Array = parseArgs( s );
			
			if (s.substr(0,4) == "new " )
			{
				s = s.substr(4, s.length - 4);
				//strip out args
				s = s.substr(0, s.indexOf("(") );
				doAssign( varPath, createObject( s, args ) );
			}
			else
			{
				//work out what the actual object is!
				
				
				doAssign( varPath, getRealValueOf( s, true )  );
			}
		}
		
		private function getRealValueOf( s : String , doAssign : Object = null ) : Object
		{
			return handleOperator( s, doAssign );
		}
		
		private function handleOperator( s : String, doAssign : Object = null ) : Object
		{
			var operator : String = null;
			var returnValue : Object;
			if (s.indexOf("+")	!=-1)  operator = "+";
			if (s.indexOf(" - ")	!=-1)  operator = " - ";
			if (s.indexOf(" * ")	!=-1)  operator = " * ";
			if (s.indexOf(" && ")	!=-1)  operator = " && ";
			if (s.indexOf(" || ")	!=-1)  operator = " || ";
			if (s.indexOf(" != ")	!=-1)  operator = " != ";
			if (s.indexOf(" / ")	!=-1)  operator = " / ";
			if (s.indexOf(" == ")	!=-1)  operator = " == ";
			
			if (operator == null )
			{
				returnValue =  processRealValue( s, doAssign );
			}
			else
			{
				var splits : Array = s.split( operator );
				returnValue = processRealValue(splits[i] );
				for (var i : int = 1; i < splits.length; i ++ )
				{
					var splitValue : Object = processRealValue(splits[i] );
					switch (operator)
					{
						case "+" :
							returnValue += splitValue;
						break;
						case " - " :
							returnValue = Number(returnValue.toString()) - Number(splitValue.toString());
						break;
						case " / " :
							returnValue = Number(returnValue.toString()) / Number(splitValue.toString());
						break;
						case " * " :
							returnValue = Number(returnValue.toString()) * Number(splitValue.toString());
						break;
						case " && " :
							returnValue = returnValue && splitValue;
						break;
						case " || " :
							returnValue = returnValue || splitValue;
						break;
						case " != " :
							returnValue = returnValue != splitValue;
						break;
						case " == " :
							returnValue = returnValue == splitValue;
						break;
						
					}
				}
			}
			return returnValue;
			
		}
		
		private function processRealValue( s : String, isAssign : Object = null ) : Object
		{
			var actualValue : Object = parsePrimitive( s, isAssign);
			return actualValue != "NO" ? actualValue : parseMethodOrAttribute( s );
		}
		
		private function parseArgs( s : String ) : Array
		{
			//get text between outer and inner brackets
			var argString : String = getOutMostArgs( s);
			if (argString.replace(" ", "") == "" ) return [];
			var args: Array = argString.split(",");
			for (var i : int = 0; i < args.length; i ++ )
			{
				args[i] = getRealValueOf( args[i] );
			}
			return args;
		}
		
		private function getOutMostArgs( s : String ) : String
		{
			var firstBracket : int = s.indexOf("(");
			var lastBracket : int = s.lastIndexOf(")");
			var temp : int = lastBracket;
			if (lastBracket==firstBracket+1) return "";
			return s.substring(firstBracket+1, lastBracket );
		}
		
		private function getVariableFromAssignment( s : String ) : Array
		{
			var fullVarName : String;
			fullVarName = s.substr(0, s.indexOf("=") );
			fullVarName = StringUtil.ltrim( StringUtil.rtrim( fullVarName ) );

			var assignments : Array = fullVarName.split(".");
			return assignments;
		}
		
		private function getAssignment( s  : String ) : String
		{
			var assignment : String;
			assignment = s.substr(s.indexOf("=")+1, s.length - s.indexOf("=")-1 );
			return StringUtil.rtrim( StringUtil.ltrim( assignment) );
		}
		

		private function doMethodCall( targetObject : Object, method: String, args:Array) : Object 
		{
			var result : Object;
			// note - would be nice to use apply/ or call, btu they don't return values..
			// :-(
			try {
			switch (args.length)
			{
				
				case 0:
					result = targetObject[method]();
				break;
				case 1:
					result = targetObject[method](args[0]  );
				break;
				case 2:
					result = targetObject[method](args[0], args[1]  );
				break;
				case 3:
					result = targetObject[method](args[0],args[1], args[2]  );
				break;
				case 4:
					result = targetObject[method](args[0], args[1],args[2], args[3], args[4]  );
				case 5:
					result = targetObject[method](args[0], args[1],args[2], args[3], args[4], args[5]  );
				case 6:
					result = targetObject[method](args[0], args[1],args[2], args[3], args[4], args[5], args[6]  );
				case 7:
					result = targetObject[method](args[0], args[1],args[2], args[3], args[4], args[5], args[6], args[7]  );
					
				break;
			}
			} catch (e : Error ) { result = "ERROR"; }
			return result;
		}
	}
}