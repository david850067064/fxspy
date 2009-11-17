package com.flexspy.imp
{
	import flash.utils.getDefinitionByName;

	public class ApplicationUtil
	{
		//this method is a helper while transitioning flex 3 to 4
		public static function getApplication() : Object{
			var appClass : Object;
			var application : Object;
			try{
				appClass = getDefinitionByName("mx.core.FlexGlobals");
				application = appClass["topLevelApplication"];
			} catch ( e : Error) {
				appClass = getDefinitionByName("mx.core.Application");
				application = appClass["application"];
			}
			return application;
		}
	}
}