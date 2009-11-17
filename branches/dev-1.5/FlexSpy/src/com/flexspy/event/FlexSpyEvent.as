package com.flexspy.event
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class FlexSpyEvent extends Event
	{
		public static const PROPERTY_SELECTED : String = "PROPERTY_SELECTED";
		public static const VIEW_ITEM_SELECTED : String = "VIEW_ITEM_SELECTED";
		public static const REFRESHED : String = "REFRESHED";
		public static const HIDE : String = "HIDE";
		public static const SHOW : String = "SHOW";
		private var _viewItem : DisplayObject;
		private var _propertyValue : Object;
		private var _propertyName : String;
		private var _associatedEvent : Event;
		
		public function FlexSpyEvent(type : String, associatedEvent : Event, viewItem : DisplayObject = null, propertyValue : Object = null, propertyName : String = null){
			super(type);
			_viewItem = viewItem;
			_propertyValue = propertyValue;
			_associatedEvent = associatedEvent;
			_propertyName = propertyName;
		}
		
		public function get viewItem() : DisplayObject{
			return _viewItem;
		}
		
		public function get propertyValue() : Object{
			return _propertyValue;
		}
		public function get propertyName() : String{
			return _propertyName;
		}
		
		public function get associatedEvent() : Event{
			return _associatedEvent;
		}
	}
}