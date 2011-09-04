package com.horizon.utils
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import gs.TweenLite;
	
	public final class VisualizerUtils
	{
		public static function saveimagetodesktop(canvas:Bitmap):void
		{
			var fileRef:FileReference = new FileReference();
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(canvas.bitmapData);
			fileRef.save(ba,"capture.jpg");
		}
		
		public static function fadeSpriteIn(sprite:Sprite):void
		{
			sprite.alpha = 0;
			sprite.visible = true;
			TweenLite.to(sprite,.5, {alpha:1});
		}
		
		public static function sendimagetofriend(canvas:Bitmap, emailTo:String, subject:String, from:String, emailFrom:String ):void
		{
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(canvas.bitmapData);
			
			var varLoader:URLLoader = new URLLoader;
			varLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			var varSend:URLRequest = new URLRequest("emailAttachment.php?emailTo="+emailTo+"&subject="+subject+"&from="+from+"&emailFrom="+emailFrom);
			//var varSend:URLRequest = new URLRequest("emailAttachment.php");
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
				
				var marginWidth:Number = (printJob.pageWidth/2) - (canvasSprite.width/2);
				var marginHeight:Number = (printJob.pageHeight/2) - (canvasSprite.height/2);
				var rect:Rectangle = new Rectangle(-marginWidth, -marginHeight,  printJob.pageWidth, printJob.pageHeight);
				if (canvasSprite.width>printJob.pageWidth) {
					canvasSprite.width=printJob.pageWidth;
					canvasSprite.scaleY=canvasSprite.scaleX;
				}
				printJob.addPage(canvasSprite, rect);
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
			var currentCanvasBitmapData:BitmapData = new BitmapData(450, 450, true);
			var area:Rectangle = new Rectangle(0, 0, 450, 450);
			var croppedCanvasBitmapData:BitmapData;
			var croppedCanvas:Bitmap;
			
			currentCanvasBitmapData.lock();
			currentCanvasBitmapData.draw(sprite1, null, null, null, area, true);
			currentCanvasBitmapData.draw(sprite2, null, null, null, area, true);
			currentCanvasBitmapData.unlock();
			
			croppedCanvasBitmapData = new BitmapData(420, 400, false);
			croppedCanvasBitmapData.lock();
			croppedCanvasBitmapData.copyPixels(currentCanvasBitmapData, new Rectangle(40, 65, 420, 400), new Point(0,0));
			croppedCanvas = new Bitmap(croppedCanvasBitmapData);
			croppedCanvas.smoothing = true;
			croppedCanvasBitmapData.unlock();
			
			croppedCanvas.x = 40;
			croppedCanvas.y = 65;
			
			return croppedCanvas;
		}
		
		public static function generateErrorBitmap(width:int, height:int):BitmapData
		{
			var textField:TextField = new TextField();
			var textBitmapData:BitmapData = new BitmapData(width, height, false, 0xFFFFFF);
			textField.text = "Image Missing.";
			textBitmapData.draw(textField);
			
			return textBitmapData
		}
		
		public static function removeChildren(sprite:Sprite):void
		{
			var numChildren:int = sprite.numChildren - 1;
			
			if(numChildren==-1)
				return;
			
			for(var i:int = numChildren; i>=0; i--)
				sprite.removeChildAt(i);
		}
	}
}