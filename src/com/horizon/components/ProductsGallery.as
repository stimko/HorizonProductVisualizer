package com.horizon.components
{
	import com.horizon.utils.VisualizerUtils;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ProductsGallery extends Tiler
	{
		private var bitmapContainer:Sprite;
		
		public function ProductsGallery(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean = false, scale:Number = 1)
		{
			initiateDisplayFunction = loadPage;
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale);
		}
		
		/*override public function checkXmlLength():void
		{
			var thexmlLength:int = theXML.client.length();
			
			if(totalImages==0 || thexmlLength < totalImages)
				totalImages = theXML.client.length();
		}
	
		override public function generateVoArray(maxIndex:int):Array
		{
			var voarray:Array = new Array;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var vo:Object = new Object;
				vo.url = String(theXML.client[i].@imageurl);
				vo.size = String(theXML.client[i].@size);	
				voarray.push(vo);
			}	
			return voarray;
		}*/
		
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
			bitmapContainer.addChild(copyBitmap);
			bitmapContainer.startDrag();
			bitmapContainer.scaleX = bitmapContainer.scaleY = ratio;
			bitmapContainer.x = mouseX - (localMouseX * (1 + scaleNum));
			bitmapContainer.y = mouseY - (localMouseY * (1 + scaleNum));
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
