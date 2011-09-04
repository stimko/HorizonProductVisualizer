package com.horizon.components
{
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
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
		
		override protected function animateTiles():void
		{
			var currentBitmapData:BitmapData;
			var currentBitmap:Bitmap;
			var currentImageHolder:Sprite;
			var currentY:int = 0;
			
			for (var a:int=0; a<specifiedNumOfColumns; a++)
			{
				currentImageHolder =  new Sprite();
				
				if(displayNames)
					currentImageHolder.addChild(createLabel(a));
				
				currentBitmapData = currentPageVosReference[a].bmData;
				currentBitmap = new Bitmap(currentBitmapData);
				currentBitmap.smoothing = true;
				currentImageHolder.addChild(currentBitmap);
				currentImageHolder.alpha = 0;
				currentImageHolder.x = (a*(totalWidth * scale));
				currentImageHolder.y = currentY;
				currentImageHolder.buttonMode = true;
				currentBitmap.scaleX = scale;
				currentBitmap.scaleY = scale;
				currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
				currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
				currentImageHolder.addEventListener(MouseEvent.MOUSE_DOWN, imageDownHandler);
				currentImagesContainer.addChild(currentImageHolder);
				TweenLite.to(currentImageHolder,1, {alpha:1, delay:(.075*a)});
			}
		}
	}
}
