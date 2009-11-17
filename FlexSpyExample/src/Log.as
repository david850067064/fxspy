package {
	import mx.collections.ArrayCollection;

    public class Log {
        private static var _instance:Log;
		private var currentFilter : Object = null;
        public static function get instance():Log {
            if (_instance == null) {
                _instance = new Log();
            }
            return _instance;
        }

        [Bindable]
        public var items:ArrayCollection = new ArrayCollection; //of String

        public function addLine(source:Object, text:Object):void {
            items.addItem(new LogItem(source, text));
        }
		
		public function filterSource(source : Object) : void{
			currentFilter = source;
			if ( source == null || !source.hasOwnProperty("name")){
				items.filterFunction = null;
			} else {
				items.filterFunction = filterItems;
			}
			items.refresh();
		}
		
		private function filterItems(item : LogItem) : Boolean{
			return ( item.source == currentFilter);
		}
    }
}