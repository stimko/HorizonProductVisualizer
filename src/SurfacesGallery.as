package
{
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gs.TweenLite;
	
	public class SurfacesGallery extends Tiler
	{
		public var currentSurface:int;
		
		public function SurfacesGallery(theXML:XML, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false)
		{
			initiateDisplayFunction = loadPage;
			super(theXML, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames);
		}
	
		override public function generateVoArray(maxIndex:int):Array
		{
			var voarray:Array = new Array;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var vo:Object = new Object;
				//vo.url = String(theXML.surface[i].item[0].@imagesrc);
				vo.url = 'assets/images/clients/brut.jpg';
				vo.displayName = String(theXML.surface[i].@name);
				voarray.push(vo);
			}	
			return voarray;
		}
		
		override public function imageDownHandler(event:MouseEvent):void
		{
			currentSurface = currentImagesContainer.getChildIndex(event.currentTarget as Sprite);
		}
		
		override public function checkXmlLength():void
		{
			var thexmlLength:int = theXML.surface.length();
			
			if(totalImages==0 || thexmlLength < totalImages)
				totalImages = theXML.surface.length();
		}
	}
}
