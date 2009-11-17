package {

    public class LogItem {
        public var source:Object;
		public var name : String;
        public var text:String;

        public function LogItem(source:Object, text:Object) {
            this.source = source;
			if ( source.hasOwnProperty("name")){
				this.name = source["name"];
			} else {
				this.name = source as String;
			}
            this.text = text as String;
        }
    }
}