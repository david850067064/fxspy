package com.flexspy.parser.model.presentation.components
{
	import com.flexspy.parser.model.domain.Snippet;
	import com.flexspy.parser.model.domain.SnippetCategory;
	import com.flexspy.parser.util.CollectionUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.ITreeDataDescriptor;

	public class SnippetsDataDescriptor implements ITreeDataDescriptor
	{
		public function getChildren( node : Object, model : Object = null ) : ICollectionView
		{
			var children : ICollectionView ;
			
			if( node is SnippetCategory )
			{
				var category : SnippetCategory = SnippetCategory( node );
									
				children = new ArrayCollection( CollectionUtil.mergeLists( [ 
														category.categories, 
														category.snippets ] ).toArray() );
				  	
			}
			else if( node is Snippet )
			{
				children = new ArrayCollection();					
			}
			else
			{
				throw new Error( "Unrecognised node type: " + node ); 
			}
			
			return children;
		}
		
		public function hasChildren( node : Object, model : Object = null ) : Boolean
		{
			return ( ( node is SnippetCategory ) && 
						( SnippetCategory( node ).categories.length>0 ) ||
						( SnippetCategory( node ).snippets.length>0 ) ); 
		}
		
		public function isBranch( node : Object, model : Object = null ) : Boolean
		{
			return node is SnippetCategory;
		}
		
		public function getData(node:Object, model:Object=null):Object
		{
			return node;
		}
		
		public function addChildAt( parent : Object, newChild:Object, index:int, model:Object=null):Boolean
		{
			//tood
			return false;
		}
		
		public function removeChildAt(parent:Object, child:Object, index:int, model:Object=null):Boolean
		{
			//todo
			return false;
		}
	}
}