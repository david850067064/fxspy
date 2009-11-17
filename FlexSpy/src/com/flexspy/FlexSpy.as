/**
 * FlexSpy 1.5
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://www.mieuxcoder.com]
 */
package com.flexspy {

	import com.flexspy.imp.ComponentTreeWnd;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import com.flexspy.FlexSpy_Internal;
	
	/**
	 * Entry point to use FlexSpy.
	 */
	public class FlexSpy {
		private static const dispatcher : EventDispatcher = new EventDispatcher();
		
		/**
		 * Displays the tree of the specified DisplayObject (its children, the children of its children, etc.)
		 * 
		 * @param root Root of the displayed tree. If it is null, the current application is used.
		 * @param modal true to display a modal window (default), false to display a modeless window.
		 */
		public static function show(root: DisplayObject = null, modal: Boolean = false): void {
			ComponentTreeWnd.show(root, modal);
		}
		
		/**
		 * Registers a key sequence that will trigger the appearance of the FlexSpy window.
		 * 
		 * @param key Sequence of keys to press to display the FlexSpy window.
		 * @param root Root of the displayed tree. If set to <code>null</code> the root window
		 * of the application is used.
		 * @param modal true to display a modal window (default), false to display a modeless window.
		 */
		public static function registerKey(key: KeySequence, root: DisplayObject = null, modal: Boolean = false): void {
			if (root == null) {
				root = DisplayObject(Application.application);
			}
			
			root.addEventListener(KeyboardEvent.KEY_DOWN, function(event: KeyboardEvent): void {
				if (key.isPressed(event)) {
					show(root, modal);
				}
			});
		}
	
		/**
		 * Adds right mouse integration for flexSpy.
		 * 
		 * This basically means when you press the right mouse button on something, it will
		 * popup the full display hierarchy under the mouse
		 * 
		 * @param target uicomponent that will have mouse button integration added.
		 */
		public static function addContextMenuTo(target:UIComponent):void {
			FlexSpyUtil.addContextMenuTo(target);
		}

		/**
		 * Registers an ActionScript method as callable from JavaScript in the container.
		 * 
		 * @param root Root of the displayed tree. If set to <code>null</code> the root window
		 * of the application is used.
		 * @param modal true to display a modal window (default), false to display a modeless window.
		 */
		public static function registerJS(root: DisplayObject = null, modal: Boolean = false, functionName: String = "flexSpy"): void {
			if (root == null) {
				root = DisplayObject(Application.application);
			}
			
			if (ExternalInterface.available) {
				ExternalInterface.addCallback(functionName, function(): void {
					show(root, modal);
				});
			}
		}
		
		/**
		 * Adds the module specified to flexSpy
		 * 
		 * The module should set it's label property - as the title - you may be interested in the events:
		 * FlexSpyEvent.PROPERTY_SELECTED
		 * FlexSpyEvent.VIEW_ITEM_SELECTED
		 * FlexSpyEvent.REFRESHED
		 * FlexSpyEvent.HIDE
		 * FlexSpyEVent.SHOW
		 * 
		 * @param modal true to display a modal window (default), false to display a modeless window.
		 */
		public static function addModule(module : Class) : void{
			ComponentTreeWnd.addModule(module);
		}
		
		/**
		 * this is used by flexspy to communicate with modules, or other parties interested in flexspy events
		 * currently supports:
		 * FlexSpyEvent.PROPERTY_SELECTED
		 * FlexSpyEvent.VIEW_ITEM_SELECTED
		 * FlexSpyEvent.REFRESHED
		 * FlexSpyEvent.HIDE
		 * FlexSpyEVent.SHOW
		 */
		public static function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority :int = 0, useWeakReference : Boolean = false ): void{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		FlexSpy_Internal static function dispatchEvent(event : Event) : void{
			dispatcher.dispatchEvent(event);
		}
	}
}