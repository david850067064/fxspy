package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.IASParser;
	import com.flexspy.parser.view.components.ObjectSpy;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.utils.describeType;
	
	import mx.controls.Tree;
	import mx.events.TreeEvent;
	
	[Event(name="hintObjectPath",type="flash.events.TextEvent")]
	public class ObjectSpyModifier extends EventDispatcher
	{
		[Bindable] public var currentObjectTree : XML;
		[Bindable] public var currentObjectTitle : String;
		private var currentObject : Object;
		private var parser : IASParser;
		private var currentObjectName : String;
		
		public function ObjectSpyModifier( parser : IASParser ) 
		{
			this.parser = parser;
		} 
		
		public function setCurrentObject ( objectName : String ) : void
		{
			currentObject = parser.getObjectByName( objectName );
			currentObjectTree = getDetailsAsXML( currentObject );
			currentObjectName = objectName;
		}
		
		public function handleDoubleClick( event : MouseEvent ) : void
		{
			var item : XML = Tree(event.currentTarget).selectedItem as XML;
			var itemName : String = getObjectNameFromXMLItem( item );
			var e : TextEvent = new TextEvent( ObjectSpy.HINT_OBJECT_PATH );
			e.text = itemName;
			dispatchEvent ( e );
		}
		
		//look up this item
		public function handleOpenItem( event : TreeEvent ) : void
		{
			var item : XML = event.item as XML;
			var itemName : String = getObjectNameFromXMLItem( item );
			var object : Object = parser.getObjectByName( itemName );
			var xmlToAdd : XML = getDetailsAsXML( object, item );
			//item.appendChild( xmlToAdd );			
		}
		
		public function handleCloseItem( event : TreeEvent ) : void
		{
			var item : XML = event.item as XML;
			//item.setChildren( null );
		}
		
		public function getDetailsAsXML( object : Object, listToAddTo : XML = null ) : XML
		{
			var returnList : XML = (listToAddTo == null) ? <root></root> : listToAddTo;
            var classInfo:XML = describeType( object );
			
            // Dump the entire E4X XML object into ta2.
            var s : String =  classInfo.localName();
            var clazzName : String = classInfo.@name.toString() ;
			if ( parser.isPrimitive( object.toString() ) || clazzName=="String")
			{
				returnList.appendChild( createBasicNode( " PRIMITIVE VALUE " + object.toString() ) );
			}
            // List the class name.
			returnList.appendChild( createBasicNode( "Class " + clazzName  ) );

            // List the object's variables, their values, and their types.
            for each (var v:XML in classInfo..variable) {
				returnList.appendChild( 
						createPropertyNode( v.@name, " (" + v.@type + ")",  object[v.@name]) );
            }
			
            // List accessors as properties.
            for each (var a:XML in classInfo..accessor) {
                // Do not get the property value if it is write only.
                try {
                	
                
                if (a.@access == 'writeonly') {
					returnList.appendChild( 
						createPropertyNode( a.@name , " (" +  a.@type + ")",  "<write only>") );
                }
                else {
					returnList.appendChild( 
						createPropertyNode( a.@name , " (" +  a.@type + ")",  object[a.@name]) );
                }
                } catch (e : Error ) {}
            } 
			
            // List the object's methods.
            for each (var m:XML in classInfo..method) {
				returnList.appendChild( 
						createMethodNode( m.@name +"()", m.@returnType ) );
            }
			return returnList;
			
        }
        
        private function createBasicNode( s : String, isBranch : Boolean = false ) : XML
        {
		    var newItem:XML = 
		    <info isBranch="false" label={ s } />	
		    return newItem;
        }
        
        private function createPropertyNode ( propertyName : String , 
        		propertyType : String, propertyValue : String,
       			isBranch : Boolean = false ) : XML
        {
        	var label:String = "P:" + propertyName + ":" + propertyType + ":" + propertyValue;
        	
        	var newItem:XML = 
		    <info isBranch={ propertyValue != null }
		        label = { label }
		        type = { propertyType }
		        name = { propertyName }
		        value = { propertyValue }
		    />	
		    return newItem;
        }
		
		private function createMethodNode ( methodName : String , 
        		returnType : String, methods : XMLList = null ) : XML
        {
        	var label:String = "M:" + methodName + ":" + returnType;
        	var newItem:XML = 
		    <info isBranch={ methods != null }
		        label = { label } 
		        name={ methodName }
		        type={ returnType }
		    />	
		    
		    if ( methods != null )
		    {
		    	newItem.appendChild( methods );
		    }
		    return newItem;
        }
		
		
		private function getObjectNameFromXMLItem( item : XML ) : String
		{
			var objNames : Array = [];
			while (item.parent() != null && item.@name != null)
			{
				objNames.push( item.@name );
				item = item.parent();
			}
			objNames.reverse();
			
			return currentObjectName+"."+objNames.join( "." );
		}
		
		
	}
}