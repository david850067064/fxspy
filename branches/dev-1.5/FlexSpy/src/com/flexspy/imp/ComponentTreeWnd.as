/**
 * FlexSpy 1.2
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://coderpeon.ovh.org]
 */
package com.flexspy.imp {

	import com.flexspy.FlexSpy;
	import com.flexspy.FlexSpy_Internal;
	import com.flexspy.event.FlexSpyEvent;
	import com.flexspy.parser.view.FlexSpyParserModule;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.containers.TabNavigator;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.Tree;
	import mx.core.IChildList;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.effects.Glow;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	/**
	 * <p>Displays details about a component and its children in a window.</p>
	 * 
	 * <p>To display the window, you call the method <code>show(root: DisplayObject, modal: Boolean)</code>.</p>
	 */
	public class ComponentTreeWnd extends ResizableTitleWindow {
		use namespace FlexSpy_Internal;
		// Only instance of our window. Non-null when window is displayed, null otherwise.
		private static var _instance: ComponentTreeWnd;

		// UI component displaying the tree of all components.
		private var _componentTree: Tree;
		
		// UI component displaying the properties of a component.
		private var _componentProperties: ComponentPropertiesEditor;

		// UI component displaying the styles of a component.
		private var _componentStyles: ComponentStylesEditor;
		
		// UI component displaying the main Windows list.
		private var _componentTreeSelection : ComboBox;
		
		// Root component of the tree
		private var _root: DisplayObject;
		
		// Indicates whether the window is displayed in a modal mode.
		private var _modal: Boolean;
		
		// Button used to highlight selected component.
		private var highlightButton: Button;
		private var highlighted : UIComponent;
		
		// Effect used to highlight the selected component
		private var _highlightComponentEffect: Effect;

		private static var isModalInstance : Boolean = true; 

		private var mainTabs : TabNavigator;
		
		private var createdChildren : Boolean;
		private var pendingModules : Array = [FlexSpyParserModule]; //of Class (defferred displayObjet)
		private var _initialSelection: DisplayObject; 
		
		private var _backUp : ComboBox; //used to go back up alevel
		
	    /**
	     * This method is not intented to be used. Use <code>show</code> method instead.
	     */
		public function ComponentTreeWnd() {
			super();
			
			// Singleton pattern
			if (_instance != null)
				throw new Error("Only one instance of ComponentTreeWnd can be created.");
			_instance = this;
			
			// properties
			this.layout = "vertical";
			this.title = "FlexSpy";
			this.width = 900;
			this.height = 678;
			this.showCloseButton = true;

			// events
			this.addEventListener("close", closeWindow);
			this.addEventListener("creationComplete", onCreationComplete);
		}
		
		override protected function createChildren(): void {
			super.createChildren();
			mainTabs = new TabNavigator();
			mainTabs.percentWidth = 100.0;
			mainTabs.percentHeight = 100.0;
			mainTabs.setStyle("color",0x000000);
			
			mainTabs.addChild(createSpyView());
			for each ( var module : Class in pendingModules){
				mainTabs.addChild(new module() as DisplayObject);
			}
			addChild(mainTabs);
			addChild(createControlBar());
			createdChildren = true;
		}
		
		private function createSpyView() : DisplayObject{
			
			var vbox: mx.containers.HDividedBox = new mx.containers.HDividedBox();
			vbox.label = "FlexSpy";
			vbox.percentWidth = 100.0;
			vbox.percentHeight = 100.0;
			
			var treeBox:mx.containers.VBox = new mx.containers.VBox();
			
			treeBox.addChild(createSpyViewHeader());
			
			_componentTree = new Tree();
			_componentTree.percentWidth = 100.0;
			_componentTree.percentHeight = 100.0;
			_componentTree.addEventListener(ListEvent.CHANGE, onItemSelected);
			_componentTree.addEventListener( MouseEvent.CLICK, onClickItem );
			_componentTree.addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClickItem );
			_componentTree.iconFunction = getTreeNodeIcon;
			treeBox.addChild(_componentTree);
			
			treeBox.percentHeight=100.0;
			treeBox.percentWidth=50.0;
			
			vbox.addChild(treeBox);
			
			var _rightTab: TabNavigator = new TabNavigator();
			_rightTab.historyManagementEnabled = false;
			_rightTab.percentWidth = 50.0;
			_rightTab.percentHeight = 100.0;
			vbox.addChild(_rightTab);
			
			_componentProperties = new ComponentPropertiesEditor();
			_componentProperties.percentWidth = 100.0;
			_componentProperties.percentHeight = 100.0;
			_rightTab.addChild(_componentProperties);

			_componentStyles = new ComponentStylesEditor();
			_componentStyles.percentWidth = 100.0;
			_componentStyles.percentHeight = 100.0;
			_rightTab.addChild(_componentStyles);
			return vbox;
		}
		private function createSpyViewHeader() : UIComponent{
			var hbox : HBox = new HBox();
			_backUp = new ComboBox();
			_backUp.addEventListener(ListEvent.CHANGE, handleBackUpChange);
			_backUp.labelField = "name";
			_backUp.rowCount = 20;
			hbox.addChild(_backUp);
			var closeAll : Button = new Button();
			closeAll.label="-";
			closeAll.addEventListener(MouseEvent.CLICK, handleCollapseClick);
			hbox.addChild(closeAll);
			var expandAll : Button = new Button();
			expandAll.label="+";
			expandAll.addEventListener(MouseEvent.CLICK, handleExpandClick);
			hbox.addChild(expandAll);
			return hbox;
		}
		
		private function handleCollapseClick(event : Event) : void{
			setTreeExpanded(false);
		}

		private function handleExpandClick(event : Event) : void{
			setTreeExpanded(true);
		}

		private function setTreeExpanded(expanded : Boolean) : void{
			if (_componentTree.dataProvider.length > 0){
				var rootNode: IComponentTreeItem = IComponentTreeItem(ArrayCollection(_componentTree.dataProvider).getItemAt(0));
				_componentTree.expandChildrenOf(rootNode, expanded);
			}
		}
		
		private function handleBackUpChange(event : ListEvent) : void{
			
			if ( _backUp.selectedItem != null){
				_root = DisplayObject(_backUp.selectedItem);
				initWindow();
			}
		}
		
		
		private function createControlBar() : UIComponent{
			var cbar: mx.containers.Box = new mx.containers.HBox();
			cbar.setStyle("horizontalAlign", "right");
			cbar.percentWidth = 100.0;
			
			var label : Label = new Label();
			label.text="Select a Popup:";
			cbar.addChild(label);
			
			_componentTreeSelection = new ComboBox();
			_componentTreeSelection.addEventListener(ListEvent.CHANGE, onTreeSelectionItemClicked);
			_componentTreeSelection.labelField = "name";
			cbar.addChild(_componentTreeSelection);
			var spacer : Spacer = new Spacer();
			spacer.percentWidth = 100;
			cbar.addChild(spacer);
			
			// Add Find button
			var findButton: Button = new Button();
			findButton.label = "Find Component";
			findButton.setStyle("icon", FindWnd.TARGET_ICON);
			findButton.addEventListener(MouseEvent.CLICK, onFindButtonClicked);
			cbar.addChild(findButton);
			
			if (!_modal) {
				// Add refresh button when window is not modal
				var refreshButton: Button = new Button();
				refreshButton.label = "Refresh";
				refreshButton.addEventListener(MouseEvent.CLICK, onRefreshButtonClicked);
				cbar.addChild(refreshButton);
			}
			highlightButton = new Button();
			highlightButton.label = "highlight";
			highlightButton.addEventListener( MouseEvent.CLICK, onHighlightClicked );
			highlightButton.y = 5;
			highlightButton.x = 160;
			cbar.addChild( highlightButton );
			return cbar;
		}
		/**
		 * Displays the tree of the specified DisplayObject (its children, the children of its children, etc.)
		 * 
		 * @param root Root of the displayed tree. If it is null, the current application is used.
		 * @param modal true to display a modal window (default), false to display a modeless window.
		 * @param initialSelection the item selected upon startup 
		 */
		public static function show(root: DisplayObject = null, modal: Boolean = true, initialSelection: DisplayObject = null): void {
			if (root == null) {
				root = DisplayObject(ApplicationUtil.getApplication());
			}
			isModalInstance = modal;
			instance.showInstance(root, initialSelection);
		}

		private function showInstance(root: DisplayObject, initialSelection: DisplayObject): void {
			_modal = isModalInstance;
			if (_root != root) {
				_root = root;
			}
			if (!visible) {
				PopUpManager.addPopUp(_instance, DisplayObject(ApplicationUtil.getApplication()), _modal);
				visible = true;
				showWindow();
			}

			_initialSelection = initialSelection;
			if (initialized) {
				initWindow();
				_initialSelection = null;
			} else {
				// initialization will be performed in the onCreationComplete() method. 				
			}
		}
		
		private static function get instance() : ComponentTreeWnd{
			if (_instance == null) {
				_instance = new ComponentTreeWnd();
				_instance.visible = false;
			}
			return _instance;
		}
		
		private function handleKey(event : KeyboardEvent) : void{
			var tabKeys : Array = [ Keyboard.F1, Keyboard.F2, Keyboard.F3, Keyboard.F4, Keyboard.F5, Keyboard.F6, Keyboard.F7, Keyboard.F8, Keyboard.F9, Keyboard.F10];
			var tabIndex : int = tabKeys.indexOf(event.keyCode);
			if ( tabIndex >-1 && tabIndex< mainTabs.numChildren){
				mainTabs.selectedIndex = tabIndex;
				this.setFocus();
			}
		}
		
		public function _addModule(module : Class) : void{
			if (createdChildren){
				mainTabs.addChild(new module());
			} else {
				pendingModules.push(module);
			}
		}
		
		public static function addModule(module : Class) : void{
			instance._addModule(module);
		}

		private function closeWindow(event: Event = null): void {
			PopUpManager.removePopUp(this);
			_instance.visible = false;
			focusManager.deactivate();
			this.removeEventListener(KeyboardEvent.KEY_UP, handleKey);
		}
		
		public function showWindow() : void{
			this.addEventListener(KeyboardEvent.KEY_UP, handleKey);
			this.setFocus();
			var flexSpyEvent : FlexSpyEvent = new FlexSpyEvent(FlexSpyEvent.SHOW,null,_root);
			FlexSpy.FlexSpy_Internal::dispatchEvent(flexSpyEvent);
		}
		
		private function onCreationComplete(event: Event): void {
			initWindow();
			_initialSelection = null;
			focusManager.activate();
			focusManager.setFocus(_componentTree);
		}

		private function onRefreshButtonClicked(event: Event): void {
			initWindow();
		}
		
		private function highlightComponent(item: ComponentTreeItem): void {
			var uiComponent: UIComponent = (item == null) ? null : (item.displayObject as UIComponent);
			if (uiComponent != null) {
				highlightComponentEffect.end();
				highlightComponentEffect.target = uiComponent;
				highlightComponentEffect.play();
			}
		}
		
		private function onFindButtonClicked(event: Event): void {
			var findWnd: FindWnd = FindWnd(PopUpManager.createPopUp(DisplayObject(ApplicationUtil.getApplication()), FindWnd, false));
			findWnd.treeWnd = this;
			PopUpManager.centerPopUp(findWnd);
			this.visible = false;
		}
		
		public function getComponentItemAt(stageX: Number, stageY: Number): ComponentTreeItem {
			var rootNode: IComponentTreeItem = IComponentTreeItem(ArrayCollection(_componentTree.dataProvider).getItemAt(0));
			var pointedItem: ComponentTreeItem = rootNode.getHitComponent(stageX, stageY, true);
			if (pointedItem != null) {
				// Adjust pointedItem to point on an UIComponent
				var uiPointedItem: IComponentTreeItem = pointedItem;
				while (uiPointedItem != null && 
						(!(uiPointedItem is ComponentTreeItem) ||
						!(ComponentTreeItem(uiPointedItem).displayObject is UIComponent))) {
					uiPointedItem = uiPointedItem.parent;
				}
			}
			pointedItem = ComponentTreeItem(uiPointedItem);
			return pointedItem;
		}
		
		public function selectComponentAt(stageX: Number, stageY: Number): void {
			var pointedItem: ComponentTreeItem = getComponentItemAt(stageX, stageY);
			selectComponent(pointedItem);
		}
		
		public function selectComponent(pointedItem: ComponentTreeItem): void {
			if (pointedItem != null) {
				// Compute the path within the tree
				var treePath: Array = new Array();
				var parent: IComponentTreeItem = pointedItem.parent;
				while (parent != null) {
					treePath.push(parent);
					parent = parent.parent;
				}
				treePath.reverse();
				
				// Collapse all nodes, then expand the path to the selected item
				var rootNode: IComponentTreeItem = IComponentTreeItem(ArrayCollection(_componentTree.dataProvider).getItemAt(0));
				_componentTree.expandChildrenOf(rootNode, false);
				for each (var treeItem: Object in treePath) {
					_componentTree.expandItem(treeItem, true, false);
				}

				// Select the item
				_componentTree.selectedItem = pointedItem;
				onItemSelected(null);
				
				// Highlight the selected item
				highlightComponentEffect.end();
				if (pointedItem.displayObject != null) {
					highlightComponentEffect.target = pointedItem.displayObject;
					highlightComponentEffect.play();
				}
			}
		}
		
		/** Fill-in the component tree with the root component.
		 * 
		 * This method is called the first time the window is created, 
		 * and when users click the "refresh" button.
		 * 
		 * @param refreshCombo boolean : true : also refresh the combo selecting the root tree.
		 * */
		private function initWindow(refreshCombo:Boolean = true): void {
			// Compute the component tree and display it
			var rootItem: IComponentTreeItem = new ComponentTreeItem(_root, null);
			var treeNodes: ArrayCollection = new ArrayCollection();
			treeNodes.addItem(rootItem);
			_componentTree.dataProvider = treeNodes;
			_componentTree.validateNow();
			_componentTree.expandItem(rootItem, true);
			
			// Compute the combo to select the tree to show
			if(refreshCombo){			
				_componentTreeSelection.dataProvider = fillTreeSelection();
			}
			_backUp.dataProvider = getBackupItems();
			if (_initialSelection == null) {
				_componentTree.expandItem(rootItem, true);
				_componentProperties.showComponentProperties(null);
				_componentStyles.showComponentStyles(null);
			} else {
				selectDisplayObject(_initialSelection);				
			}
		}
		
		private function getBackupItems() : ArrayCollection{
			var items : ArrayCollection = new ArrayCollection();
			var item : DisplayObject = _root ? _root.parent : null;
			while (item != null && !(item is Stage)){
				items.addItem(item);
				item = item.parent;
			}
			return items;
		}
		
		private function onTreeSelectionItemClicked(event:ListEvent): void {
			_root = DisplayObject(_componentTreeSelection.selectedItem);
			initWindow();
		}
		
		private function fillTreeSelection(): ArrayCollection {
			var windowsArray:ArrayCollection = new ArrayCollection();
			listWindows(windowsArray,systemManager.popUpChildren);
			listWindows(windowsArray,systemManager);
			return windowsArray;
		}
		
		private function listWindows(windowsArray:ArrayCollection, list:IChildList): void{
			for (var i:int=0;i<list.numChildren;i++) {
				var currentWindow:DisplayObject = list.getChildAt(i);
				if (currentWindow == _instance) {
					break;
				}
				var component:UIComponent = currentWindow as UIComponent;
				if (component == null) {
					break;
				}
				component = component.owner as UIComponent;
				while(component != null){
					if(component == _instance){
						break;
					}
					component = component.owner as UIComponent;
				}
				windowsArray.addItem(currentWindow);
			}
		}
		
		private function selectDisplayObject(displayObject: DisplayObject): void {
			if (displayObject == null) {
				return;
			}
			var item: ComponentTreeItem = getItemByDisplayObject(displayObject) as ComponentTreeItem;
			this.selectComponent(item);
		}
		
		private function onItemSelected(event: Event): void {
			updateSelection(selectedComponent as ComponentTreeItem);
		}
		
		private function updateSelection(item: ComponentTreeItem): void {
			var displayObject: DisplayObject = (item == null) ? null : item.displayObject;
			_componentProperties.showComponentProperties(displayObject);
			_componentStyles.showComponentStyles(displayObject);
			highlightComponent(item);
		}
		
		private function onClickItem( event : MouseEvent ) : void{
			dispatchSelectionEvent(selectedDisplayObject, event);
		}
		
		private function onDoubleClickItem(event : MouseEvent) : void{
			_root = ComponentTreeItem(selectedComponent).displayObject;
			var items : Array = [_root.parent];
			initWindow();
		}
		
		private function dispatchSelectionEvent(item : DisplayObject, event : Event) : void{
			var flexSpyEvent : FlexSpyEvent = new FlexSpyEvent(FlexSpyEvent.VIEW_ITEM_SELECTED, event, item);
			FlexSpy.FlexSpy_Internal::dispatchEvent(flexSpyEvent);
		}
        
        private function get selectedComponent(): IComponentTreeItem {
			return (_componentTree.selectedItem as IComponentTreeItem);
        }
		
		private function get selectedDisplayObject() : DisplayObject{
			var item: ComponentTreeItem = selectedComponent as ComponentTreeItem;
			return (item == null) ? null : item.displayObject;
		}
		
		private function getItemByDisplayObject(displayObject: DisplayObject): IComponentTreeItem {
			var result: IComponentTreeItem;
			for each (var item: IComponentTreeItem in _componentTree.dataProvider) {
				result = item.getItemByDisplayObject(displayObject);
				if (result != null) {
					return result;
				}
			}
			// Not found
			return null;
		}
        
		private function getTreeNodeIcon(item:Object):Class{
		   return IComponentTreeItem(item).icon;
		}

		private function get highlightComponentEffect(): Effect {
			if (_highlightComponentEffect == null) {
				var glow: Glow = new Glow();
				glow.color = 0xFFFF00;
				glow.strength = 10;
				glow.inner = false;
				glow.duration = 1000;
				_highlightComponentEffect = glow;
			}
			return _highlightComponentEffect;
		}
		
		private function onHighlightClicked(event: Event): void {
			highlightButton.label = highlightButton.label == 'highlight' ? 'unhighlight' : 'highlight';
			highlighted = selectedDisplayObject as UIComponent;
			if ( highlighted )
			{
				if ( highlightButton.label != 'highlight' )
				{
					var glow:GlowFilter = new GlowFilter();
					glow.color = 0xFFFF00;
					glow.alpha = 1;
					glow.blurX = 0;
					glow.blurY = 0;
					glow.strength = 10;
					glow.inner = false;
					glow.quality = BitmapFilterQuality.MEDIUM;
					
					highlighted.filters = [glow];
				}
				else
				{
					highlighted.filters = [];
				}
			}
		}
	}
}
