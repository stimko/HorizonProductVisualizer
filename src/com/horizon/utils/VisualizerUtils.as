package com.horizon.utils
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	public final class VisualizerUtils
	{
		public static function saveimagetodesktop(canvas:Sprite):void
		{
			var snapshotBitmapData:BitmapData = new BitmapData(500, 500);
			snapshotBitmapData.draw(canvas);
			
			var fileRef:FileReference = new FileReference();
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(snapshotBitmapData);
			fileRef.save(ba,"capture.jpg");
		}
		
		public static function sendimagetofriend(canvas:Sprite):void
		{
			//addChild(tiler);
			var snapshotBitmapData:BitmapData = new BitmapData(500, 500);
			snapshotBitmapData.draw(canvas);
			
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(snapshotBitmapData);
			
			var varLoader:URLLoader = new URLLoader;
			//varLoader.addEventListener(Event.COMPLETE, complete);
			varLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			var varSend:URLRequest = new URLRequest("emailAttachment.php");
			varSend.method = URLRequestMethod.POST;
			varSend.data = ba;
			
			varLoader.load(varSend);
		}
		
		public static function copyBitmapData(bitmap:Bitmap):Bitmap
		{
			var copyBitmapData:BitmapData = bitmap.bitmapData;	
			var copyBitmap:Bitmap = new Bitmap(copyBitmapData);
			
			return copyBitmap;
		}
	}
}