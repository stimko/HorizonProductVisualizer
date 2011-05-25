package
{
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	public class ProductsGallery extends Tiler
	{
		public function ProductsGallery(theXML:XML, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean = false)
		{
			initiateDisplayFunction = loadPage;
			super(theXML, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames);
		}
		
		override public function checkXmlLength():void
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
		}
		
		override public function imageOverHandler(event:MouseEvent):void
		{
			event.currentTarget.addChild(createBorder(0x9E9C9A));	
		}
		
		override public function imageOutHandler(event:MouseEvent):void
		{
			var currentImage:Sprite = event.currentTarget as Sprite;
			currentImage.removeChild(currentImage.getChildAt(currentImage.numChildren-1));	
		}
	}
}
