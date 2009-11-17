package com.flexspy.parser.model
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public interface IASParser extends IEventDispatcher 
	{
		
		function processString( s: String ) : void;
		function addVariable(varName : String, value : Object ) : void;
		function getObjectByName( objectName : String ) : Object;
		function isPrimitive( s : String ) : Boolean;
		function getVariables() : ArrayCollection;
		
	}
}