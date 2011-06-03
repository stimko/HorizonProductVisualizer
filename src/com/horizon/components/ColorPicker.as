package com.horizon.components
{
	import com.horizon.events.ColorSwatchEvent;
	import com.horizon.utils.MaskUtil;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import gs.TweenLite;
	
	public class ColorPicker extends Tiler
	{
		private var imageContainer:Sprite =  new Sprite;
		private var previousContainer:Sprite = new Sprite;
		private var isAnimating:Boolean = false;
		private var bmMaskSprite:Sprite;
		private var colorBitmap:Bitmap;
		
		public function ColorPicker(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false, scale:Number = 1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = animateTiles;
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
			addChild(imageContainer);
			loadColorImage();
		}
		
		override protected function imageDownHandler(event:MouseEvent):void
		{
			if(isAnimating)
				return;
			
			assignCurrentSelected(event.currentTarget as Sprite);
			
			if(previouslySelected != currentSelected)
				if(!currentVO.bmData)
					loadColorImage();
				else
					displayColorImage();
		}
		
		private function loadColorImage():void
		{
			var imageLoader:Loader = new Loader();
			var image:URLRequest = new URLRequest (currentVO.url);
			imageLoader.load(image);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		private function onLoadComplete(event:Event):void
		{
			var bm:Bitmap = event.currentTarget.content as Bitmap;
			currentVO.bmData = bm.bitmapData;
			displayColorImage();
		}
		
		private function displayColorImage():void
		{
			previousContainer = imageContainer;
			imageContainer = new Sprite();
			addChild(imageContainer);
			imageContainer.alpha = 0;
			colorBitmap = new Bitmap(currentVO.bmData);
			colorBitmap.smoothing = true;
			//colorBitmap.scaleX = .75;
			//colorBitmap.scaleY = .75;
			imageContainer.addChild(colorBitmap);
			//colorBitmap.y = -colorBitmap.height + 25;
			colorBitmap.y = 60;
			TweenLite.to(imageContainer,.5, {alpha:1, onComplete:removePreviousContainer});
			isAnimating = true;
			
			if(!bmMaskSprite)
				createAndDisplayMask();
		}
		
		private function createAndDisplayMask():void
		{
			//bmMask = MaskUtil.convertPngToMask(currentVO.bmData);
			//bm.scaleX = .75;
			//bm.scaleY = .75;
			var maskBitmap:Bitmap = new Bitmap(currentVO.bmData);
			bmMaskSprite = new Sprite();
			bmMaskSprite.addChild(maskBitmap);
			bmMaskSprite.cacheAsBitmap = true;
		
			
			dispatchEvent(new ColorSwatchEvent(bmMaskSprite, ColorSwatchEvent.MASK_READY, true));
			//addChild(bm);
		}
		override public function reAnimate():void
		{
			removeChild(currentImagesContainer);
			animateTiles();
			imageContainer.alpha = 0;
			animateImageContainer();
		}
		
		private function animateImageContainer():void
		{
			TweenLite.to(imageContainer,.5, {alpha:1});
		}
		
		private function removePreviousContainer():void
		{
			isAnimating = false;
			removeChild(previousContainer);
		}
		
		override public function animateTiles():void
		{
			var currentSwatch:Sprite;
			var currentHexString:String;
			var currentHex:uint;
			var currentSwatchHolder:Sprite;
			var imageNumber:int = 0;
			var currentY:int = 0;
			var numOfColumns:int = specifiedNumOfColumns;
			var numberOfSwatchesToAnimate:int = currentPageVosReference.length;
			
			currentImagesContainer = new Sprite();
			addChild(currentImagesContainer);
			currentImagesContainer.y = 50;
			
			for(var i:int = 1; i<=numOfRows; i++)
			{
				currentY = ((i-1)*totalHeight) + startingY;
				var tileDifference:int = (i*specifiedNumOfColumns) - numberOfSwatchesToAnimate;
				
				if(tileDifference > 0)
					numOfColumns = specifiedNumOfColumns - tileDifference;
				
				for (var a:int=0; a<numOfColumns; a++)
				{
					currentSwatchHolder =  new Sprite();
					currentSwatch = new Sprite();
					
					currentHexString = '0x' + currentPageVosReference[imageNumber].hex;
					
					currentHex = uint(currentHexString);
					
					currentSwatch.graphics.beginFill(currentHex);
					currentSwatch.graphics.drawRect(0, 0, imageWidth, imageHeight);
					currentSwatch.graphics.endFill();
					
					currentSwatchHolder.addChild(currentSwatch);
					currentSwatchHolder.alpha = 0;
					currentSwatchHolder.x = (a*totalWidth) + startingX;
					currentSwatchHolder.y = currentY;
					currentSwatchHolder.buttonMode = true;
					//currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
					//currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
					currentSwatchHolder.addEventListener(MouseEvent.MOUSE_DOWN, imageDownHandler);
					currentImagesContainer.addChild(currentSwatchHolder);
					TweenLite.to(currentSwatchHolder,1, {alpha:1, delay:(.075*imageNumber)});
					imageNumber++;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
