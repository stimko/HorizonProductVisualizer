package com.horizon.components
{
	import assets.swfs.ui.clearSurfaceButton;
	
	import com.horizon.events.ColorSwatchEvent;
	import com.horizon.events.TilerEvent;
	import com.horizon.utils.VisualizerUtils;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import gs.TweenLite;
	
	public class ProductsGallery extends Tiler
	{
		private var bitmapContainer:Sprite;
		private var maskSprite:Sprite;
		private const maskSpriteHeight:int = 70;
		
		public function ProductsGallery(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean = false, scale:Number = 1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = loadPage;
			addEventListener(ColorSwatchEvent.MASK_READY, onMaskReady);
			addEventListener(TilerEvent.CLEANUP_CONTENT, cleanUpSupportContent);
			supportContentContainer = new Sprite();
			addChild(supportContentContainer);
			createClearSurfaceButton();
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
		}
		
/*		override protected function imageOverHandler(event:MouseEvent):void
		{
			event.currentTarget.addChild(createBorder(0x9E9C9A));	
		}
		
		override protected function imageOutHandler(event:MouseEvent):void
		{
			var currentImage:Sprite = event.currentTarget as Sprite;
			currentImage.removeChild(currentImage.getChildAt(currentImage.numChildren-1));	
		}*/
		
		private function createClearSurfaceButton():void
		{
			var clearButton:clearSurfaceButton = new clearSurfaceButton();
			clearButton.x = 350;
			clearButton.y = 460;
			addChild(clearButton);
			clearButton.addEventListener(MouseEvent.CLICK, clearTheSurface);
		}
		
		private function clearTheSurface(event:MouseEvent):void
		{
			while(supportContentContainer.numChildren>0)
				supportContentContainer.removeChildAt(0)
		}
		
		override protected function imageDownHandler(event:MouseEvent):void
		{
			currentSelected = currentImagesContainer.getChildIndex(event.currentTarget as Sprite);
			currentVO = currentPageVosReference[currentSelected];
			
			var ratio:Number = getRatio(event.target as Sprite);
			var scaleNum:Number = (ratio - scale)*2;
			
			var copyBitmap:Bitmap = VisualizerUtils.copyBitmapData(event.target.getChildAt(0));
			copyBitmap.smoothing = true;
			
			bitmapContainer = new Sprite();
			bitmapContainer.scaleX = bitmapContainer.scaleY = .5;
			bitmapContainer.startDrag();
			bitmapContainer.addChild(copyBitmap);
			bitmapContainer.scaleX = bitmapContainer.scaleY = ratio;
			bitmapContainer.x = mouseX - (bitmapContainer.width/2);
			bitmapContainer.y = mouseY - (bitmapContainer.height/2);
			bitmapContainer.buttonMode = true;
			//TweenLite.to(bitmapContainer,3, {scaleX:ratio, scaleY:ratio});
			addChild(bitmapContainer);
			applyDropShadow(bitmapContainer);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
			bitmapContainer.addEventListener(MouseEvent.MOUSE_DOWN, productMouseDown);
		}
		
		override public function reAnimate(animateContentContainer:Boolean=true):void
		{
			VisualizerUtils.removeChildren(currentImagesContainer);
			if(animateContentContainer)
				animateproductsContainer();
			animateTiles();
		}
		
		private function animateproductsContainer():void
		{
			supportContentContainer.alpha = 0;
			TweenLite.to(supportContentContainer,.5, {alpha:1});
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			checkDragBoundaries(event);
		}
		
		private function productMouseDown(event:MouseEvent):void
		{
			bitmapContainer = event.currentTarget as Sprite;
			bitmapContainer.y += maskSpriteHeight;
			addChild(bitmapContainer);
			bitmapContainer.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
			bitmapContainer.removeEventListener(MouseEvent.MOUSE_DOWN, productMouseDown);
			applyDropShadow(bitmapContainer);
		}
		
		private function checkDragBoundaries(event:MouseEvent):void
		{
			if(event.stageX<0 || event.stageX>stage.stageWidth || event.stageY<0 || event.stageY>stage.stageHeight){
				removeMouseListeners();
				bitmapContainer.stopDrag();
				removeChild(bitmapContainer);
			}
		}
		
		private function ceaseDraggage(event:MouseEvent):void
		{
			removeMouseListeners();
			removeDropShadow(bitmapContainer);
			bitmapContainer.stopDrag();
			bitmapContainer.y -= maskSpriteHeight;
			bitmapContainer.addEventListener(MouseEvent.MOUSE_DOWN, productMouseDown);
			supportContentContainer.addChild(bitmapContainer);
		}
		
		private function removeMouseListeners():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMaskReady(event:ColorSwatchEvent):void
		{	
			supportContentContainer.y = maskSpriteHeight;
			
			supportContentContainer.cacheAsBitmap = true;
			maskSprite = event.maskSprite;
			maskSprite.y = maskSpriteHeight;
			
			addChild(maskSprite);
			supportContentContainer.mask = maskSprite;
		}
		
		private function applyDropShadow(sprite:Sprite):void
		{
			var my_shadow:DropShadowFilter = new DropShadowFilter(); 
			my_shadow.color = 0x000000;  
			my_shadow.blurY = 2;  
			my_shadow.blurX = 2;  
			my_shadow.angle = 150;  
			my_shadow.alpha = .5;  
			my_shadow.distance = 3;
			my_shadow.quality = 3;
			
			var filtersArray:Array = new Array(my_shadow);  
			
			sprite.filters = filtersArray;
		}
		
		private function cleanUpSupportContent(event:Object):void
		{
			VisualizerUtils.removeChildren(supportContentContainer);
		}
		
		private function removeDropShadow(sprite:Sprite):void
		{
			sprite.filters = [];
		}
		
		private function getRatio(bmc:Sprite):Number
		{
			var ratio:Number;
			var size:String = currentVO.size;
			
			switch(size)
			{
				case 'small':
					ratio = .5;
					break;
				case 'medium':
					ratio = .75;
					break;
				case 'large':
					ratio =  1;
					break;
			}
			return ratio;
		}
	}
}
