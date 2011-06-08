package com.horizon.utils
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.printing.PrintJob;
	import flash.utils.ByteArray;
	
	public final class VisualizerUtils
	{
		public static function saveimagetodesktop(canvas:Bitmap):void
		{
			var fileRef:FileReference = new FileReference();
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(canvas.bitmapData);
			fileRef.save(ba,"capture.jpg");
		}
		
		public static function sendimagetofriend(canvas:Bitmap):void
		{
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(canvas.bitmapData);
			
			var varLoader:URLLoader = new URLLoader;
			//varLoader.addEventListener(Event.COMPLETE, complete);
			varLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			var varSend:URLRequest = new URLRequest("emailAttachment.php");
			varSend.method = URLRequestMethod.POST;
			varSend.data = ba;
			
			varLoader.load(varSend);
		}
		
		public static function printCanvas(canvas:Bitmap):void
		{
			var printJob:PrintJob = new PrintJob();
			var copyBitmapData:BitmapData = canvas.bitmapData.clone();
			var copyBitmap:Bitmap = new Bitmap(copyBitmapData);
			copyBitmap.smoothing = true;
			var canvasSprite:Sprite = new Sprite();
			canvasSprite.addChild(copyBitmap);
			
			if (printJob.start()) {
				
				if (canvasSprite.width>printJob.pageWidth) {
					canvasSprite.width=printJob.pageWidth;
					canvasSprite.scaleY=canvasSprite.scaleX;
				}
				printJob.addPage(canvasSprite);
				printJob.send();
			}
		}
	
	public static function copyBitmapData(bitmap:Bitmap):Bitmap
	{
		var copyBitmapData:BitmapData = bitmap.bitmapData;	
		var copyBitmap:Bitmap = new Bitmap(copyBitmapData);
		
		return copyBitmap;
	}
	
	public static function loadFrameImage():Loader
	{
		var imageLoader:Loader = new Loader();
		var image:URLRequest = new URLRequest('assets/images/products/vis-embellishmentbox-img.png');
		imageLoader.load(image);
		
		return imageLoader;
	}
	
	public static function captureCreationArea(sprite1:Sprite, sprite2:Sprite):Bitmap
	{
		var bmp:BitmapData = new BitmapData(450, 450, true);
		var area:Rectangle = new Rectangle(10, 10, 450, 450);
		var currentCanvas:BitmapData;
		var croppedCanvas:Bitmap;
		
		bmp.draw(sprite1, null, null, null, area, true);
		bmp.draw(sprite2, null, null, null, area, true);
		
		currentCanvas = bmp;
		
		croppedCanvas = VisualizerUtils.crop(10, 55, 450, 400, currentCanvas); 
		croppedCanvas.y = 65;
		croppedCanvas.x = 25;
		
		return croppedCanvas;
	}
	
	public static function crop( _x:Number, _y:Number, _width:Number, _height:Number, bitmapData:BitmapData):Bitmap
	{
		var cropArea:Rectangle = new Rectangle( 0, 0, _width, _height );
		var croppedBitmap:Bitmap = new Bitmap( new BitmapData( _width, _height ), PixelSnapping.ALWAYS, true );
		croppedBitmap.bitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, -_x, -_y) , null, null, cropArea, true );
		return croppedBitmap;
	}
}
}