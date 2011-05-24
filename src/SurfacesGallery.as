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
		public function SurfacesGallery(sourceUrl:String, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, numofImagesToLoad:int=0, displayNames:Boolean=false)
		{
			super(sourceUrl, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, numofImagesToLoad, displayNames);
		}
	
		override public function generateVoArray(maxIndex:int):Array
		{
			var voarray:Array = new Array;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var vo:Object = new Object;
				vo.url = String(clients.client[i].@imageurl);
				vo.displayName = String(clients.client[i].@name);
				voarray.push(vo);
			}	
			return voarray;
		}
	}
}
