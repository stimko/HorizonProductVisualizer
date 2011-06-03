package com.horizon.components
{
	import com.horizon.events.ColorSwatchEvent;
	import com.horizon.events.ProductEvent;
	import com.horizon.utils.VisualizerUtils;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	public class ProductsGallery extends Tiler
	{
		private var bitmapContainer:Sprite;
		private var productsMaskedContainer:Sprite;
		private var maskSprite:Sprite;
		
		public function ProductsGallery(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean = false, scale:Number = 1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = loadPage;
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
			addEventListener(ColorSwatchEvent.MASK_READY, onMaskReady);
		}
		
		override protected function imageOverHandler(event:MouseEvent):void
		{
			event.currentTarget.addChild(createBorder(0x9E9C9A));	
		}
		
		override protected function imageOutHandler(event:MouseEvent):void
		{
			var currentImage:Sprite = event.currentTarget as Sprite;
			currentImage.removeChild(currentImage.getChildAt(currentImage.numChildren-1));	
		}
		
		override protected function imageDownHandler(event:MouseEvent):void
		{
			currentSelected = currentImagesContainer.getChildIndex(event.currentTarget as Sprite);
			currentVO = currentPageVosReference[currentSelected];
			
			var localMouseX:int = event.target.mouseX;
			var localMouseY:int = event.target.mouseY;
			var ratio:Number = getRatio(event.target as Sprite);
			var scaleNum:Number = (ratio - scale)*2;
			
			var copyBitmap:Bitmap = VisualizerUtils.copyBitmapData(event.target.getChildAt(0));
			copyBitmap.smoothing = true;
			
			bitmapContainer = new Sprite();
			bitmapContainer.scaleX = bitmapContainer.scaleY = .5;
			bitmapContainer.addChild(copyBitmap);
			bitmapContainer.startDrag();
			bitmapContainer.scaleX = bitmapContainer.scaleY = ratio;
			bitmapContainer.x = mouseX - (bitmapContainer.width/2);
			bitmapContainer.y = mouseY - (bitmapContainer.height/2);
			//TweenLite.to(bitmapContainer,3, {scaleX:ratio, scaleY:ratio});
			addChild(bitmapContainer);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			bitmapContainer.addEventListener(MouseEvent.MOUSE_DOWN, moveProduct);
			bitmapContainer.stopDrag();
			bitmapContainer.buttonMode = true;
			bitmapContainer.y -= 60;
			productsMaskedContainer.addChild(bitmapContainer);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(event.stageX<0 || event.stageX>stage.stageWidth || event.stageY<0 || event.stageY>stage.stageHeight){
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				bitmapContainer.stopDrag();
				removeChild(bitmapContainer);
			}
		}
		
		private function moveProduct(event:MouseEvent):void
		{
			event.currentTarget.startDrag();
			event.currentTarget.addEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
		}
		
		private function ceaseDraggage(event:MouseEvent):void
		{
			event.currentTarget.stopDrag();	
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
		}
		
		private function onMaskReady(event:ColorSwatchEvent):void
		{
			productsMaskedContainer = new Sprite();
			
/*			var whiteSquare:Sprite = new Sprite();
			whiteSquare.graphics.beginFill(0xFFFFFF);
			whiteSquare.graphics.drawRect(0,0,500,380);
			whiteSquare.graphics.endFill();
			productsMaskedContainer.addChild(whiteSquare);*/
			productsMaskedContainer.y = 60;
			addChild(productsMaskedContainer);
			
			productsMaskedContainer.cacheAsBitmap = true;
			maskSprite = event.maskSprite;
			maskSprite.y = 60;
			
			addChild(maskSprite);
			productsMaskedContainer.mask = maskSprite;
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
