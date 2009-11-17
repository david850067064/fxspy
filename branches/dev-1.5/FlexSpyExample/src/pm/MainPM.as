package pm
{
	import mx.controls.Alert;
	
	public class MainPM
	{
		[Bindable] 
		public var selectedIndex : int = 0;
		
		[Bindable]
		public var model1 : TestViewPM = new TestViewPM( "view1", 0xff0000 );
		
		[Bindable]
		public var model2 : TestViewPM = new TestViewPM( "view2", 0x00ff00 );
		
		[Bindable]
		public var model3 : TestViewPM = new TestViewPM( "view3", 0xffffff );
		
		
		[Bindable]
		public var models : Array = [ model1, model2, model3 ];
		
		
		public function nextView() : void
		{
			if (selectedIndex < 2) selectedIndex++;
		}
		
		public function previousView() : void
		{
			if (selectedIndex >-1 ) selectedIndex--;
		}
		
		public function saySomething( message : String ) : void
		{
			Alert.show( message );
		}
	}
}