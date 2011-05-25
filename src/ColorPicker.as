package
{
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	public class ColorPicker extends Tiler
	{
		public function ColorPicker(theXML:XML, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false)
		{
			initiateDisplayFunction = animateTiles;
			super(theXML, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames);
		}
		
		override public function checkXmlLength():void{
			var thexmlLength:int = theXML.item.length();
			
			if(totalImages==0 || thexmlLength < totalImages)
				totalImages = theXML.item.length();
		};
		
		override public function generateVoArray(maxIndex:int):Array
		{
			var voarray:Array = new Array;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var vo:Object = new Object;
				//vo.url = String(theXML.item[i].@imageurl);
				vo.hex = String(theXML.item[i].@hex);
				voarray.push(vo);
			}	
			return voarray;
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
				currentY = (i-1)*totalHeight;
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
					currentSwatchHolder.x = a*totalWidth;
					currentSwatchHolder.y = currentY;
					currentSwatchHolder.buttonMode = true;
					//currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
					//currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
					currentImagesContainer.addChild(currentSwatchHolder);
					TweenLite.to(currentSwatchHolder,1, {alpha:1, delay:(.075*imageNumber)});
					imageNumber++;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
