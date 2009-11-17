package com.flexspy.parser.model.presentation.panels
{
	import com.flexspy.parser.model.ASParser;
	import com.flexspy.parser.model.FlexTrampModelLocator;
	
	import mx.collections.ArrayCollection;
	
	public class VariabesPanelModifier
	{
		[Bindable] public var variables : ArrayCollection;
		[Bindable] private var parser : ASParser;
		public function VariabesPanelModifier( parser : ASParser ) 
		{
			this.parser = parser;
			this.variables = this.parser.displayVariables;
		}
		public function setV(  )  : void
		{
			var model : FlexTrampModelLocator = FlexTrampModelLocator.getInstance();
			this.parser = parser;
			this.variables = this.parser.displayVariables;
		}
	}
}