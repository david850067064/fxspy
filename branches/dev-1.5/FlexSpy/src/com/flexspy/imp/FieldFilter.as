package com.flexspy.imp
{
	import com.flexspy.parser.util.StringUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.Label;

	public class FieldFilter extends HBox
	{
		/**
		 * A combobox that has a list of contents that can be modified
		 * and has common filters in it
		 */
		private var defaultSO : SharedObject;
		private var combo : ComboBox;
		private var add : Button;
		private var tip : String = "seperate filter items with a space or comma, press add to store in your favourites list";
		private var dataProvider : ArrayCollection;
		
		public function FieldFilter(soName : String, defaults : Array)
		{
			defaultSO = SharedObject.getLocal(soName);
			var items : Array = defaultSO.data.defaults == null ? defaults : defaultSO.data.defaults;
			dataProvider = new ArrayCollection(items);
		}
		
		
		override protected function createChildren() : void
		{
			super.createChildren();
			var label : Label = new Label();
			label.text = "Filter";
			addChild(label);
			combo = new ComboBox();
			combo.editable = true;
			combo.dataProvider = dataProvider;
			combo.addEventListener("change",handleChange);
			combo.rowCount = 12;
			combo.maxWidth=200;
			combo.dropdownWidth=400;
			addChild(combo);
			add = new Button();
			addChild(add);
			add.label="add";
			add.addEventListener(MouseEvent.CLICK, handleAdd);
		}
		
		private function handleChange(event : Event) : void{
			event.stopImmediatePropagation();
			event.stopPropagation();
			
			var regextext :String = combo.text;
			if ( StringUtil.trim(regextext)==""){
				regextext =null;
			} else {
				regextext = regextext.replace(/,/g,"|");
				regextext = regextext.replace(/\ /g,"|");
				regextext = "(" + regextext +")";
			}
			
			dispatchEvent( new TextEvent("change",false,false,regextext));
		}
		
		private function handleAdd(event :MouseEvent) : void{
			if ( event.altKey){
				var index : int = dataProvider.getItemIndex(combo.text);
				dataProvider.removeItemAt(index);
				combo.text = "";
			}else {
				if ( dataProvider.getItemIndex(combo.text) == -1){
					dataProvider.addItem(combo.text);
				}
			}
			defaultSO.data.defaults = ArrayCollection(dataProvider).toArray();
			defaultSO.flush();			
		}
	}
}