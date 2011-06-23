package com.horizon.events
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ColorSwatchEvent extends Event
	{
		public static const MASK_READY:String = "maskReady";
		
		public var maskSprite:Sprite;
		
		public function ColorSwatchEvent(maskSprite:Sprite, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.maskSprite = maskSprite;
		}
		
		override public function clone():Event {
			return new ColorSwatchEvent(maskSprite, type);
		}
	}
}