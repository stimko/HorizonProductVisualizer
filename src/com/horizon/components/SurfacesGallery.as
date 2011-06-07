package com.horizon.components
{
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SurfacesGallery extends Tiler
	{
		public var currentSurface:int;
		
		public function SurfacesGallery(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false, scale:Number=1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = loadPage;
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
		}
		
		override protected function imageDownHandler(event:MouseEvent):void
		{
			assignCurrentSelected(event.currentTarget as Sprite);
			dispatchEvent(new Event('newSurfaceSelected', true));
		}
	}
}
