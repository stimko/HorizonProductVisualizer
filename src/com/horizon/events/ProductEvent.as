package com.horizon.events
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ProductEvent extends Event
	{
		public static const PRODUCT_DROPPED:String = "productDropped";
		
		public var currentProduct:Sprite;
		
		public function ProductEvent(currentProduct:Sprite, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.currentProduct = currentProduct;
		}
	}
}