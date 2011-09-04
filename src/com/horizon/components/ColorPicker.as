package com.horizon.components
{
	import com.horizon.events.ColorSwatchEvent;
	import com.horizon.events.TilerEvent;
	import com.horizon.utils.VisualizerUtils;
	import com.horizon.utils.VisualizerVanity;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import gs.TweenLite;
	
	public class ColorPicker extends Tiler
	{
		private var previousContainer:Sprite;
		private var isAnimating:Boolean = false;
		private var bmMaskSprite:Sprite = new Sprite();
		private var colorBitmap:Bitmap;
		private var previousBitmap:Bitmap;
		private const surfaceY:int = 70;
		private var surfaceWidth:int = 0;
		private var surfaceHeight:int = 0;
		
		public function ColorPicker(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false, scale:Number = 1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = animateTiles;
			createContainers();
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
			loadColorImage();
			addEventListener(TilerEvent.REPOPULATE, rePopulate);
		}
		
		private function createContainers():void
		{
			previousContainer = new Sprite();
			addChild(previousContainer);
			previousContainer.y = surfaceY;
			supportContentContainer = new Sprite();
			addChild(supportContentContainer);
		}
		
		override protected function imageDownHandler(event:MouseEvent):void
		{
			if(isAnimating)
				return;
			
			assignCurrentSelected(event.currentTarget as Sprite);
			
			if(previouslySelected != currentSelected)
				checkIfBitmapDataAvailable()
		}
		
		private function checkIfBitmapDataAvailable():void
		{
			if(!currentVO.bmData)
				loadColorImage();
			else
			{
				VisualizerUtils.removeChildren(supportContentContainer);
				surfaceHeight = currentVO.bmData.height;
				surfaceWidth = currentVO.bmData.width;
				displayColorImage();
			}
		}
		
		private function loadColorImage():void
		{
			var imageLoader:Loader = new Loader();
			var image:URLRequest = new URLRequest (VisualizerVanity.FashionArtsURL+currentVO.url);
			imageLoader.load(image);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorLoadingSurface);
		}
		
		private function onLoadComplete(event:Event):void
		{
			currentVO.bmData = Bitmap(event.currentTarget.content).bitmapData;
			
			if(surfaceHeight==0)
			{
				surfaceWidth = currentVO.bmData.width;
				surfaceHeight = currentVO.bmData.height;
			}
			
			displaySurface();
		}
		
		private function errorLoadingSurface(event:IOErrorEvent):void
		{
			currentVO.bmData = VisualizerUtils.generateErrorBitmap(surfaceWidth==0?surfaceWidth:300, surfaceHeight==0?surfaceHeight:300);
			displaySurface();
		}
		
		private function displaySurface():void
		{
			VisualizerUtils.removeChildren(supportContentContainer);
			displayColorImage();
		}
		
		private function displayColorImage():void
		{
			if(previousVO)
			{
				previousBitmap = new Bitmap(previousVO.bmData);
				previousContainer.addChild(previousBitmap);
				previousBitmap.x = 240 - (surfaceWidth/2);
			}
			
			supportContentContainer.alpha = 0;
			colorBitmap = new Bitmap(currentVO.bmData);
			colorBitmap.smoothing = true;
			colorBitmap.x = 240 - (surfaceWidth/2);
			supportContentContainer.addChild(colorBitmap);
			colorBitmap.y = surfaceY;
			TweenLite.to(supportContentContainer,.5, {alpha:1, onComplete:removePreviousContainer});
			isAnimating = true;
			
			if(bmMaskSprite.numChildren==0)
				createAndDisplayMask();
		}
		
		private function createAndDisplayMask():void
		{
			//bmMask = MaskUtil.convertPngToMask(currentVO.bmData);
			//bm.scaleX = .75;
			//bm.scaleY = .75;
			var maskBitmap:Bitmap = new Bitmap(currentVO.bmData);
			maskBitmap.x = colorBitmap.x;
			maskBitmap.y = colorBitmap.y;
			bmMaskSprite.addChild(maskBitmap);
			bmMaskSprite.cacheAsBitmap = true;
			
			dispatchEvent(new ColorSwatchEvent(bmMaskSprite, ColorSwatchEvent.MASK_READY, true));
		}
		override public function reAnimate(animateContentContainer:Boolean=true):void
		{
			VisualizerUtils.removeChildren(currentImagesContainer);
			animateTiles();
			if(animateContentContainer)
				animateImageContainer();
		}
		
		private function animateImageContainer():void
		{
			supportContentContainer.alpha = 0;
			TweenLite.to(supportContentContainer,.5, {alpha:1});
		}
		
		private function removePreviousContainer():void
		{
			isAnimating = false;
			VisualizerUtils.removeChildren(previousContainer);
		}
		
		override protected function animateTiles():void
		{
			var currentSwatch:Sprite;
			var currentHexString:String;
			var currentHex:uint;
			var currentSwatchHolder:Sprite;
			
			for (var a:int=0; a<specifiedNumOfColumns; a++)
			{
				currentSwatchHolder =  new Sprite();
				currentSwatch = new Sprite();
				
				currentHexString = '0x' + currentPageVosReference[a].hex;
				
				currentHex = uint(currentHexString);
				
				currentSwatch.graphics.beginFill(currentHex);
				currentSwatch.graphics.lineStyle(1,0xCCCCCC);
				currentSwatch.graphics.drawRect(0, 0, imageWidth, imageHeight);
				currentSwatch.graphics.endFill();
				
				currentSwatchHolder.addChild(currentSwatch);
				currentSwatchHolder.alpha = 0;
				currentSwatchHolder.x = (a*totalWidth) + currentImagesContainer.x;
				currentSwatchHolder.buttonMode = true;
				//currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
				//currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
				currentSwatchHolder.addEventListener(MouseEvent.MOUSE_DOWN, imageDownHandler);
				currentImagesContainer.addChild(currentSwatchHolder);
				TweenLite.to(currentSwatchHolder,1, {alpha:1, delay:(.075*a)});
			}
			//}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function rePopulate(event:TilerEvent):void
		{
			this.vos = event.vos;
			vosLength = vos.length;
			specifiedNumOfColumns = 0;
			VisualizerUtils.removeChildren(supportContentContainer);
			VisualizerUtils.removeChildren(bmMaskSprite);
			VisualizerUtils.removeChildren(currentImagesContainer);
			currentIndex=0;
			previousVO = null;
			currentSelected = 0;
			surfaceHeight = 0;
			surfaceWidth = 0;
			init();
			checkIfBitmapDataAvailable();
		}
	}
}
