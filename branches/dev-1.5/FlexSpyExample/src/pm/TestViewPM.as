package pm
{
	import mx.controls.Alert;
	
	public class TestViewPM
	{
		[Bindable]
		public var name : String;
		
		[Bindable]
		public var color : uint;
		
		
		public function TestViewPM( name : String, color : uint )
		{
			this.name = name;
			this.color = color;
		}
		
		public function sayHello() : void
		{
			Alert.show( "hello" );
		}

	}
}