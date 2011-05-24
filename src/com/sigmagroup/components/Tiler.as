/**
 * @author:
 * 		Stephen Timko -		stimko@sigmagroup.com
 * 		
 * 
 * 		
 */
package com.sigmagroup.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gs.TweenLite;
	
	public class Tiler extends Sprite
	{
		private var sourceUrl:String;
		private var specifiedNumOfRows:int;
		private var imagesPerPage:int;
		private var tilesLoaded:int;
		private var horPadding:int;
		private var vertPadding:int;
		private var totalImages:int;
		private var totalPages:int = 1;
		private var numberOfImagesToLoadNext:int;
		private var currentPage:int = 1;
		private var reachedTheEnd:Boolean = false;
		private var bitmap:Boolean;
		private var paginate:Boolean;
		private var namesReference:Array = new Array();
		private var imageLoaders:Vector.<Loader>;
		private var displayNames:Boolean;
		private var pageVosReference:Array = new Array();
		
		protected var imageWidth:int;
		protected var imageHeight:int;
		protected var thexml:XML;
		protected var numOfRows:int
		protected var specifiedNumOfColumns:int;
		protected var totalWidth:int;
		protected var totalHeight:int;
		protected var currentIndex:int;
		protected var currentPageVosReference:Array = new Array();
		protected var initiateDisplayFunction:Function = loadPage;
		
		public var currentImagesContainer:Sprite;
		
		public function Tiler( sourceUrl:String, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int = 1, totalImages:int = 0, displayNames:Boolean = false)
		{
			this.sourceUrl = sourceUrl;
			this.specifiedNumOfRows = specifiedNumOfRows;
			this.specifiedNumOfColumns = specifiedNumOfColumns;
			this.imageWidth = imageWidth;
			this.imageHeight = imageHeight;
			this.horPadding = horPadding;
			this.vertPadding = vertPadding;
			this.paginate = paginate;
			this.bitmap = bitmap;
			this.displayNames = displayNames;
			
			this.numOfRows = this.specifiedNumOfRows;
			this.imagesPerPage = specifiedNumOfRows * specifiedNumOfColumns;
			this.totalWidth = imageWidth + horPadding;
			this.totalHeight = imageHeight + vertPadding;
			this.currentIndex = 0;
			this.totalImages = totalImages;
			
			init();
		}
		
		private function init():void
		{
			loadTheXml();
		}
		
		private function loadTheXml():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			loader.load(new URLRequest(sourceUrl));
		}
		
		private function xmlLoaded(event:Event):void
		{	
			thexml = new XML(event.target.data);
			var thexmlLength:int = thexml.client.length();
			
			if(totalImages==0 || thexmlLength < totalImages)
				totalImages = thexml.client.length();
			
			if(paginate)
				totalPages = Math.ceil(totalImages/imagesPerPage);
			
			setupPages();	
		}
		
		private function setupPages():void
		{	
			for(var i:int = 1; i<=totalPages; i++)
			{
				if(totalPages>1)
					createPageNumber(i);
				
				generatePageVosReference(i);
			}
		}
		
		private function generatePageVosReference(pageNumber:int):void {
			var voarray:Array = new Array;
			var maxIndex:int;
			
			if(pageNumber != totalPages)
				maxIndex = currentIndex + imagesPerPage;
			else
			{
				reachedTheEnd = true;
				
				if(paginate)
				{
					var urlsLeft:int = totalImages - currentIndex;
					maxIndex = currentIndex + urlsLeft;
				}
				else
					maxIndex = totalImages;	
			}
			
			voarray = generateVoArray(maxIndex);
			
			pageVosReference[pageNumber] = voarray;
			currentIndex += imagesPerPage;
			
			if(reachedTheEnd)
			{
				currentPageVosReference = pageVosReference[1];
				initiateDisplay();
			}
		}
		
		private function createPageNumber(pageNumber:int):void
		{
			var tfmc:MovieClip = new MovieClip();
			var tf:TextField = new TextField();
			tf.text = pageNumber.toString();
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT; 
			tf.addEventListener(MouseEvent.MOUSE_DOWN, navigateToPage);
			
			var myFormat:TextFormat = new TextFormat();  
			myFormat.color = 0xAA0000; 
			myFormat.size = 24;  
			myFormat.italic = true;  
			tf.setTextFormat(myFormat);
			
			tfmc.x = 30*pageNumber;
			tfmc.y = 10;
			tfmc.addChild(tf);
			tfmc.buttonMode = true;
			addChild(tfmc);
		}
		
		private function navigateToPage(event:MouseEvent):void
		{
			var pageNumber:int = int(event.currentTarget.text); 
			if(pageNumber != currentPage)
			{
				currentPage = pageNumber;
				currentPageVosReference = pageVosReference[currentPage];
				
				removeChild(currentImagesContainer);
				
				if(currentPageVosReference[0].bmData)
					animateTiles();
				else
					loadPage();
			}
		}
		
		private function onLoadComplete(event:Event):void
		{
			tilesLoaded++;
			
			if (tilesLoaded == numberOfImagesToLoadNext)
			{
				storeBitmapData();
				tilesLoaded = 0;
				animateTiles();
			}
		}
		
		private function storeBitmapData():void
		{				
			for(var i:int = 0; i<numberOfImagesToLoadNext; i++)
			{
				var bitmap:Bitmap = imageLoaders[i].content as Bitmap;
				currentPageVosReference[i].bmData = bitmap.bitmapData;
			}
		}
		
		private function createLabel(imageNumber:int):TextField
		{
			var tf:TextField = new TextField();
			tf.text = currentPageVosReference[imageNumber].displayName;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT; 
			
			var myFormat:TextFormat = new TextFormat("Comic Sans MS"); 
			myFormat.color = 0x000000; 
			myFormat.size = 24;  
			myFormat.italic = true;  
			tf.setTextFormat(myFormat);	
			
			tf.x = (imageWidth/2) - (tf.width/2);
			tf.y = (imageHeight + 10);
			return tf;
		}
		
		private function loadPage():void
		{	
			imageLoaders = new Vector.<Loader>;
			numberOfImagesToLoadNext = currentPageVosReference.length;
			
			for each(var vo:Object in currentPageVosReference)
			{
				var imageLoader:Loader = new Loader();
				var image:URLRequest = new URLRequest (vo.url);
				imageLoader.load(image);
				imageLoaders.push(imageLoader);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			}
		}
		
		public function getSize(imageNumber:int):String
		{
			return currentPageVosReference[imageNumber].size;
		}
		
		//POSSIBLY OVERIDDEN METHODS
		public function initiateDisplay():void{initiateDisplayFunction();};
		public function generateVoArray(maxIndex:int):Array{ return new Array()};
		public function createBorder(color:uint):DisplayObject
		{
			var border:Shape = new Shape();
			border.graphics.lineStyle(1,color);
			border.graphics.drawRect(0, 0, imageWidth, imageHeight);
			
			return border;
		}
		
		public function imageOverHandler(event:MouseEvent):void
		{
			event.currentTarget.addChild(createBorder(0x9E9C9A));	
		}
		
		public function imageOutHandler(event:MouseEvent):void
		{
			var currentImage:Sprite = event.currentTarget as Sprite;
			currentImage.removeChild(currentImage.getChildAt(currentImage.numChildren-1));	
		}
		public function animateTiles():void
		{
			var currentBitmapData:BitmapData;
			var currentBitmap:Bitmap;
			var currentImageHolder:Sprite;
			var imageNumber:int = 0;
			var currentY:int = 0;
			var numOfColumns:int = specifiedNumOfColumns;
			var numberOfImagesToAnimate:int = currentPageVosReference.length;
			
			currentImagesContainer = new Sprite();
			addChild(currentImagesContainer);
			currentImagesContainer.y = 50;
			
			for(var i:int = 1; i<=numOfRows; i++)
			{
				currentY = (i-1)*totalHeight;
				var tileDifference:int = (i*specifiedNumOfColumns) - numberOfImagesToAnimate;
				
				if(tileDifference > 0)
					numOfColumns = specifiedNumOfColumns - tileDifference;
				
				for (var a:int=0; a<numOfColumns; a++)
				{
					currentImageHolder =  new Sprite();
					
					if(displayNames)
						currentImageHolder.addChild(createLabel(imageNumber));
					
					currentBitmapData = currentPageVosReference[imageNumber].bmData;
					currentBitmap = new Bitmap(currentBitmapData);
					currentBitmap.smoothing = true;
					currentImageHolder.addChild(currentBitmap);
					currentImageHolder.alpha = 0;
					currentImageHolder.x = a*totalWidth;
					currentImageHolder.y = currentY;
					currentImageHolder.buttonMode = true;
					currentImageHolder.addChild(createBorder(0xCEA97B))
					currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
					currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
					currentImagesContainer.addChild(currentImageHolder);
					TweenLite.to(currentImageHolder,1, {alpha:1, delay:(.075*imageNumber)});
					imageNumber++;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}