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
		public function ProductsGallery(sourceUrl:String, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean = false)
		{
			super(sourceUrl, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames);
		}
	
		override public function generateVoArray(maxIndex:int):Array
		{
			var voarray:Array = new Array;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var vo:Object = new Object;
				vo.url = String(thexml.client[i].@imageurl);
				vo.size = String(thexml.client[i].@size);	
				voarray.push(vo);
			}	
			return voarray;
		}
	}
}
