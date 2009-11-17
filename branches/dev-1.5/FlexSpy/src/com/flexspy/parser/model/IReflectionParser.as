package com.flexspy.parser.model
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;

	public interface IReflectionParser extends IEventDispatcher
	{
		function get ( s : String ) : ArrayCollection;
	}
}