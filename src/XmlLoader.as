package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XmlLoader extends EventDispatcher
	{
		public var content:XML;
		
		public function XmlLoader(sourceUrl:String)
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			loader.load(new URLRequest(sourceUrl));
		}
		
		private function xmlLoaded(event:Event):void
		{
			content = new XML(event.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}