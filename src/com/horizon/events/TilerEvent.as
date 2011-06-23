package com.horizon.events
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class TilerEvent extends Event
	{
		public static const CLEANUP_CONTENT:String = "cleanupContent";
		public static const REPOPULATE:String = "repopulate";
		
		public var vos:Vector.<Object>;
		
		public function TilerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, vos:Vector.<Object>=null)
		{
			this.vos = vos;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new TilerEvent(type);
		}
	}
}