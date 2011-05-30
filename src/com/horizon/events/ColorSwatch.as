package com.horizon.events
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class GetCurrentVOandMC extends Event
	{
		public static const ON_TILE_CLICKED:String = "onTileClicked";
		
		public var vo:Object;
		public var currentSprite:Sprite;
		
		public function GetCurrentVOandMC(vo:Object, currentSprite:Sprite, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.vo = vo;
			this.currentSprite = currentSprite;
		}
	}
}