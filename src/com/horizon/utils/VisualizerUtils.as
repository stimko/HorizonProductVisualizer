package com.horizon.utils
{
	import assets.swfs.ui.*;
	
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import gs.TweenLite;
	
	public final class VisualizerUtils
	{
		public static function saveimagetodesktop(canvas:Bitmap):void
		{
			var bmData:BitmapData = compositeWithLogos(canvas);
			var fileRef:FileReference = new FileReference();
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(bmData);
			fileRef.save(ba,"MyFashionArtProject.jpg");
		}
		
		public static function fadeSpriteIn(sprite:DisplayObject):void
		{
			sprite.alpha = 0;
			sprite.visible = true;
			TweenLite.to(sprite,.5, {alpha:1});
		}
		
		public static function compositeWithLogos(canvas:Bitmap):BitmapData
		{
			var horiLogo:horizonLogo = new horizonLogo();
			var nextLogo:nextStyleLogo = new nextStyleLogo();
			var canvasWidth:int = canvas.width;
			var bmData:BitmapData = new BitmapData(500, 500, false, 0xFFFFFF);
			var translateMatrix:Matrix = new Matrix();
			translateMatrix.translate(new int(250-(canvasWidth/2)), 75);
			var logoMatrix:Matrix = new Matrix();
			logoMatrix.translate(new int(500-horiLogo.width-10), 10);
			var nextStyleMatrix:Matrix = new Matrix();
			nextStyleMatrix.translate(10, 10);
			
			bmData.lock();
			bmData.draw(canvas, translateMatrix)
			bmData.draw(horiLogo, logoMatrix);
			bmData.draw(nextLogo, nextStyleMatrix);
			bmData.unlock();
			
			return bmData;
		}
		
		public static function sendimagetofriend(canvas:Bitmap, emailTo:String, from:String, emailFrom:String ):void
		{
			var bmData:BitmapData = compositeWithLogos(canvas);
			
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(bmData);
			
			var varLoader:URLLoader = new URLLoader;
			varLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			var varSend:URLRequest = new URLRequest("visualizer/emailAttachment.php?emailTo="+emailTo+"&from="+from+"&emailFrom="+emailFrom);
			varSend.method = URLRequestMethod.POST;
			varSend.data = ba;
			
			varLoader.load(varSend);
		}
		
		public static function printCanvas(canvas:Bitmap):void
		{
			var printJob:PrintJob = new PrintJob();
			var horiLogo:horizonLogo = new horizonLogo();
			var nextLogo:nextStyleLogo = new nextStyleLogo();
			var copyBitmapData:BitmapData = canvas.bitmapData.clone();
			var copyBitmap:Bitmap = new Bitmap(copyBitmapData);
			copyBitmap.smoothing = true;
			var canvasSprite:Sprite = new Sprite();
			canvasSprite.addChild(copyBitmap);
			canvasSprite.addChild(horiLogo);
			canvasSprite.addChild(nextLogo);
			
			if (printJob.start()) {
				
				var marginWidth:Number = new int((printJob.pageWidth/2) - (canvasSprite.width/2));
				var marginHeight:Number = new int((printJob.pageHeight/2) - (canvasSprite.height/2));
				nextLogo.x-=marginWidth;
				nextLogo.y-=marginHeight;
				horiLogo.x = new int(printJob.pageWidth - horiLogo.width) - 70;
				horiLogo.y -= marginHeight;
				
				var rect:Rectangle = new Rectangle(-marginWidth, -marginHeight,  printJob.pageWidth, printJob.pageHeight);
				if (copyBitmap.width>printJob.pageWidth) {
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
			var image:URLRequest = new URLRequest('visualizer/assets/images/products/vis-embellishmentbox-img.png');
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
			
			croppedCanvasBitmapData = new BitmapData(440, 400, false);
			croppedCanvasBitmapData.lock();
			croppedCanvasBitmapData.copyPixels(currentCanvasBitmapData, new Rectangle(20, 65, 440, 400), new Point(0,0));
			croppedCanvas = new Bitmap(croppedCanvasBitmapData);
			croppedCanvas.smoothing = true;
			croppedCanvasBitmapData.unlock();
			
			croppedCanvas.x = 20;
			croppedCanvas.y = 65;
			
			return croppedCanvas;
		}
		
		public static function validateEmail(email:String, nameText:String, fromEmail:String):Boolean
		{
			var emailExpression:RegExp=/^[a-z0-9][-._a-z0-9]*@([a-z0-9][-_a-z0-9]*\.)+[a-z]{2,6}$/;
			
			if(!emailExpression.test(email) || nameText.length==0 || !emailExpression.test(fromEmail))
			return false;
			else
			return true;
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