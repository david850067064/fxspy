package com.flexspy {
   import com.flexspy.imp.ComponentTreeWnd;
   import com.flexspy.imp.Utils;
   
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.events.ContextMenuEvent;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   import mx.core.UIComponent;
   import mx.managers.SystemManager;

   public class FlexSpyUtil {
      private var contextItemMap:Dictionary;

      public function FlexSpyUtil() {
         contextItemMap = new Dictionary();
      }
	  
      internal static function addContextMenuTo(target:UIComponent):void {
         if (target == null) {
            return;
         }

         target.contextMenu = new ContextMenu();
         target.contextMenu.hideBuiltInItems();
         var identifier:FlexSpyUtil = new FlexSpyUtil();
         target.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, identifier.createContextMenuItems);
      }

      public function createContextMenuItems(event:ContextMenuEvent):void {
         event.target.customItems = getContextMenuItems(event.mouseTarget).concat(getUIHierarchyItems(event.mouseTarget));
      }

      private function getUIHierarchyItems(item:InteractiveObject):Array {
         var result:Array = new Array();
		 var depth: String = "";
         while (item != null) {
         	if (item is SystemManager) {
         		break; // Stop at the System manager level.
         	}
            var contextItem:ContextMenuItem = new ContextMenuItem(depth + getItemLabel(item));
            contextItemMap[contextItem] = item;
            contextItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleContextMenuItemSelect);

            result.push(contextItem);
            item = item.parent;
          	depth = "." + depth;	
         }
         if (result.length > 0) {
            ContextMenuItem(result[0]).separatorBefore = true;
         }
         return result;
      }

      private function getContextMenuItems(item:InteractiveObject):Array {
         var result:Array = new Array();
         while (item != null) {
            if (item is ContextMenuItemsProvider) {
               if (result.length > 0) {
                  ContextMenuItem(result[0]).separatorBefore = true;
               }

               result = ContextMenuItemsProvider(item).getContextMenuItems().concat(result);
            }
            item = item.parent;
         }
         return result;
      }

      private function getItemLabel(object:InteractiveObject):String {
         var className:String = getQualifiedClassName(object);

         return object.toString().split('.').pop() + " -- " + className
      }

      private function handleContextMenuItemSelect(event:ContextMenuEvent):void {
         var item:ContextMenuItem = ContextMenuItem(event.target);
         if (contextItemMap[item] == null)
            return;

		 var component:InteractiveObject = InteractiveObject(contextItemMap[item]);
		 var componentRoot: DisplayObject = Utils.getRoot(component);
		 ComponentTreeWnd.show(componentRoot, false, component);
      }
   }
}