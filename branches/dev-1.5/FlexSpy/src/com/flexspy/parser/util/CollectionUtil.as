package com.flexspy.parser.util
{
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	public class CollectionUtil
	{
		public static function mergeLists( listArray : Array ) : IList
		{
			var returnList : IList = new ArrayCollection();
			
			for( var i : int = 0 ; i < listArray.length ; i++ ) 
			{
				var list : IList = IList( listArray[i] );
				
				for( var x : int = 0 ; x < list.length ; x++ )
				{
					returnList.addItem( list.getItemAt( x ) );
				} 
			}
			
			return returnList;
		}
	}
}