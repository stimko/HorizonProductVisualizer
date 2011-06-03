package com.horizon.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.geom.Point;

	public final class MaskUtil
	{
		public static function convertPngToMask(pngBitmapData:BitmapData):Bitmap 
		{
			var pt:Point = new Point(0, 0);
			
			var matteBitmapData:BitmapData = new BitmapData(pngBitmapData.width, pngBitmapData.height, true);
			matteBitmapData.copyChannel(pngBitmapData, pngBitmapData.rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			matteBitmapData.copyChannel(pngBitmapData, pngBitmapData.rect, pt, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
			matteBitmapData.copyChannel(pngBitmapData, pngBitmapData.rect, pt, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			var matteBitmap:Bitmap = new Bitmap(matteBitmapData);
			return matteBitmap;
		}
	}
}