package com.flexspy.parser.util
{
	import flash.display.DisplayObject;
	
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	public class PopUpUtil
	{
		public static function addCenteredPopUp( popUp : IFlexDisplayObject,
				modal : Boolean = true ) : void {
					
			PopUpManager.addPopUp( popUp,
				DisplayObject( Application.application ),
				modal );
			
			PopUpManager.centerPopUp( popUp );
		}
	}
}