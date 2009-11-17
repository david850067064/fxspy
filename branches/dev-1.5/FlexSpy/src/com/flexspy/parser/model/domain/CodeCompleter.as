package com.flexspy.parser.model.domain
{
	import com.flexspy.parser.model.IASParser;
	import com.flexspy.parser.util.StringUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	[Event(name="Selected", type="flash.events.TextEvent")]
	public class CodeCompleter extends EventDispatcher
	{
		public static var SELECTED : String = "Selected";
				
		[Bindable] public var active : Boolean = false;
		[Bindable] public var matches : ArrayCollection = new ArrayCollection();
		[Bindable] public var debugText : String = "";
		
		private var parser : IASParser;
		private var currentPhrase : String;
		
		private var currentPhaseRegExp : RegExp = new RegExp("(\s|\(\[)*.*$","g");
		public function CodeCompleter( parser : IASParser )
		{
			this.parser = parser;
		}
		
		private function debug( s : String ) : void
		{
			debugText += "\n" + s;
		}
		
		public function updateCodeComplete( s : String ) : void
		{
			debug ("updating with " + s);
			//check to see if the existing string is a substring of this
			if ( !active ) return;
			//check if either string is a substring of the other.
			var isLongerSubstring : Boolean = s.indexOf( currentPhrase ) == 0;
			var isShorterSubstring : Boolean = s.indexOf( s ) == 0;
			
			var lastChar : String = s.charAt( s.length -1  );
			if ( ( !isLongerSubstring && !isShorterSubstring)  || lastChar=="."  ) 
			{
				start( s );
				return;
			}
			
			if ( s.charAt( s.length ) == "." )
			{
				//reget the matches
				getCodeCompleteMatches( s );
			} else
			{
				updateFilterfunction( getPartOfPhrase( s, true ) );
			}
			matches.refresh();
        	updateStatus( s );
		}

		//then filter based on remainder
		public function getCodeCompleteMatches( s : String ) : void
		{
			debug ("getting matches with " + s);
			var activePhrase : String = getCurrentCodePhrase( s );
			var filterPhrase : String = getPartOfPhrase( activePhrase, true );
			var objectPhrase : String = getPartOfPhrase( activePhrase );
			var matchedAClass : Boolean;
			var targetObject : Object;
			if ( activePhrase.indexOf(".") == -1 ) 
			{
				getCodeCompleteFromVariableSpace( activePhrase );
				return;
			}
			try {
				targetObject = parser.getObjectByName( objectPhrase );
			} catch ( e : Error ) {}
			
			//TODO - put some code here to cehck if it's a package lookup
			if ( targetObject == null )
			{
				//first try a class lookup
				try {
					targetObject = getDefinitionByName( objectPhrase );
				} catch ( e : Error ) {}
				try {
					if (targetObject == null ) 	targetObject = getDefinitionByName( activePhrase );
				} catch ( e : Error ) {}
				if (targetObject == null ) 
					matches = null;
				else
					matchedAClass = true;
			}
			if (targetObject != null)
			{
				getMethodsAndPropertiesFor( targetObject, filterPhrase, matchedAClass );
			}
			
		}
		
		private function getCodeCompleteFromVariableSpace( filterPhrase : String = "" ) : void
		{
			matches = new ArrayCollection();
			matches.disableAutoUpdate();
			var c : IViewCursor = parser.getVariables().createCursor();
			while ( !c.afterLast )
			{
				matches.addItem( { label: String( c.current ) } );
				c.moveNext();
			}
			
			if ( filterPhrase.length > 0 ) updateFilterfunction( filterPhrase );
			
			matches.refresh();
			matches.enableAutoUpdate();
		}
		
		public function getCurrentMatchString () : String
		{
			return currentPhrase;	
		}
        
        public function start( s : String ) : void 
        {
        	debug ("starting with " + s);
        	getCodeCompleteMatches( s );
        	updateStatus( s )
        }
        
        public function reset() : void
        {
        	matches = new ArrayCollection();
        	active = false;
        	debug (">>>have been reset ");
        }
        
        //returns the actual active bit of code from a current phrase
        private function getCurrentCodePhrase( s : String ) : String
        {
    	    //TODO - get the active code phrase
    	    var phraseObj : Array = currentPhaseRegExp.exec( s );
    	    
    	    s = phraseObj == null ? StringUtil.trim( s ) : phraseObj[ 0 ];
    	    return s;
        }
        
        public function getMatchedPartOfCurrentPhrase() : String
        {
        		return getLastPartOfPhrase( currentPhrase );
        }
        
        //gets either the bit before, or after the last dot
        private function getPartOfPhrase( s : String, 
        		getFilterPhrase : Boolean = false ) : String
        {
			var lastDotIndex : int =  s.lastIndexOf(".");
			var hasObject : Boolean =  lastDotIndex != -1; 
			var filterPhrase : String ="";

			if ( hasObject ) 
			{
				filterPhrase = s.substring(hasObject ? lastDotIndex +1 : 0 , s.length );
			}
			var objectPhrase : String = hasObject ? s.substr(0, lastDotIndex ) : filterPhrase;
        	
        	if ( getFilterPhrase )
        		return hasObject ? filterPhrase : s;
        	else
        		return objectPhrase;
        }
        
        private function getLastPartOfPhrase ( s : String ) : String
        {
        	var r : String = getPartOfPhrase( s, true );
        	if ( r.length >0 ) return r;
        	return getPartOfPhrase( s );
        	
        }
        
		private function updateFilterfunction( phrase : String ) : void
		{
			matches.filterFunction =  function ( o : Object ) : Boolean {
					return String( o.label ).indexOf( phrase ) == 0 ;
				}
		}
		
		//TODO - mve to object spy?
		private function getMethodsAndPropertiesFor ( target: Object, 
				filterPhrase : String = "", classPropertiesOnly : Boolean = false ) : void
		{
            var classInfo:XML = describeType( target );
			
            //get the name incase we need it
            var s : String =  classInfo.localName();
            var clazzName : String = classInfo.@name.toString() ;

			matches = new ArrayCollection();
			matches.disableAutoUpdate();
			var labelText : String;
			
            // List the object's variables, their values, and their types.
            var variables : XMLList;
            var accessors : XMLList;
            var methods : XMLList;
            
            if ( classPropertiesOnly ) 
            {
            	variables = classInfo..variable;
            	accessors = classInfo..accessor.(@declaredBy == clazzName );
            	methods = classInfo..method.(@declaredBy == clazzName );
            }
            else
            {
            	variables = classInfo..variable;
            	accessors = classInfo..accessor;
            	methods = classInfo..method;
            }
            for each (var v:XML in variables) {
            	labelText = v.@name;
				matches.addItem( { label : labelText }  );
            }
			
            // List accessors as properties.
            for each (var a:XML in accessors) {
                // Do not get the property value if it is write only.
                try {
                	labelText = a.@name;
					matches.addItem( { label : labelText } );
                } catch (e : Error ) {}
            } 
			
            // List the object's methods.
            for each (var m:XML in methods) {
            	labelText = m.@name;
				matches.addItem( { label : labelText } );
            }
            
            //now sort the list
            addSort();
            if ( filterPhrase.length>0 ) updateFilterfunction( filterPhrase );
            matches.refresh();
			matches.enableAutoUpdate();
        }

       
		private function addSort() : void
		{
			var sort: Sort = new Sort();
			sort.fields = [ new SortField("label", true ) ];
			matches.sort = sort;
		}
		
        private function updateStatus( s : String ) : void
        {
        	if ( matches == null ) 
        	{
        		active = false;
        		currentPhrase = "";
        		matches = new ArrayCollection();
        		debug ("status: NULL MATCH " + s);
        		return;
        	}
        	
        	if ( matches.length == 0 )
        	{
        		//only option myst've been s
        		/*var e : TextEvent = new TextEvent( SELECTED );
        		if ( active )
        		{
        			var comp : String = getLastPartOfPhrase( currentPhrase );
    				e.text = getLastPartOfPhrase( getDifference(comp, s ) );
        		} else
        		{
        			e.text = getLastPartOfPhrase( s );
        		}
        		dispatchEvent( e );
        		*/
        		active = false;
        		currentPhrase = "";
        		debug ("status NO MATCH " + s);
        		return;
        	}
        	//there are matches, and we are active with this phrase
        	currentPhrase = s;
        	active = true;
        	debug ("status match with " + s);
        }
        
	}
}