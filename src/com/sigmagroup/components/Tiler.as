/**
 * @author:
 * 		Stephen Timko -		stimko@sigmagroup.com
 * 		
 * 
 * 		
 */
package com.sigmagroup.components
{
	import com.horizon.utils.VisualizerUtils;
	import com.horizon.utils.VisualizerVanity;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gs.TweenLite;
	
	public class Tiler extends Sprite
	{
		private var specifiedNumOfRows:int;
		private var imagesPerPage:int;
		private var imagesLoaded:int;
		private var horPadding:int;
		private var vertPadding:int;
		private var totalPages:int = 1;
		private var numberOfImagesToLoadNext:int;
		private var currentPage:int = 1;
		private var reachedTheEnd:Boolean = false;
		private var bitmap:Boolean;
		private var paginate:Boolean;
		private var imageLoaders:Vector.<Loader>;
		private var pageVosReference:Array = new Array();
		private var maxAmountOfImages:int;
		
		public var currentSelected:int;
		public var supportContentContainer:Sprite;
		
		protected var vos:Vector.<Object> = new Vector.<Object>;
		protected var vosLength:int;
		protected var displayNames:Boolean;
		protected var previouslySelected:int;
		protected var scale:Number;
		protected var currentVO:Object;
		protected var previousVO:Object;
		protected var totalImages:int;
		protected var imageWidth:int;
		protected var imageHeight:int;
		protected var specifiedNumOfColumns:int;
		protected var totalWidth:int;
		protected var totalHeight:int;
		protected var currentIndex:int;
		protected var currentPageVosReference:Vector.<Object> = new Vector.<Object>();
		protected var initiateDisplayFunction:Function;
		protected var currentImagesContainer:Sprite;
		
		public function Tiler( vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int = 1, maxAmountofImages:int = 0, displayNames:Boolean = false, scale:Number = 1, startingX:int = 0, startingY:int= 0)
		{
			this.specifiedNumOfRows = specifiedNumOfRows;
			this.specifiedNumOfColumns = specifiedNumOfColumns;
			this.imageWidth = imageWidth;
			this.imageHeight = imageHeight;
			this.horPadding = horPadding;
			this.vertPadding = vertPadding;
			this.paginate = paginate;
			this.bitmap = bitmap;
			this.displayNames = displayNames;
			this.scale = scale;
			this.vos = vos;
			this.vosLength = vos.length;
			this.imagesPerPage = specifiedNumOfRows * specifiedNumOfColumns;
			this.totalWidth = imageWidth + horPadding;
			this.totalHeight = imageHeight + vertPadding;
			this.currentIndex = 0;
			this.totalImages = this.maxAmountOfImages = maxAmountofImages;
			
			createCurrentImagesContainer(startingX, startingY);
			
			init();
		}
		
		protected function init():void
		{	
			checkAmountOfVos();
			checkColumns();
			checkRows();
			
			if(paginate)
				totalPages = Math.ceil(totalImages/imagesPerPage);
			
			setupPages();	
		}
		
		private function createCurrentImagesContainer(xPos:int, yPos:int):void
		{
			currentImagesContainer = new Sprite();
			currentImagesContainer.x = xPos;
			currentImagesContainer.y = yPos;
			addChild(currentImagesContainer);
		}
		
		private function checkAmountOfVos():void
		{
			if(maxAmountOfImages==0 || vosLength < maxAmountOfImages)
				totalImages = vosLength;
			else
				totalImages = maxAmountOfImages; 
		}
		
		protected function checkColumns():void
		{
			if(specifiedNumOfColumns>totalImages || specifiedNumOfColumns==0)
				specifiedNumOfColumns = totalImages;
		}
		
		private function checkRows():void
		{
			if(specifiedNumOfRows>totalImages)
				specifiedNumOfRows = totalImages;
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
			var voarray:Vector.<Object> = new Vector.<Object>;
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
				currentVO = currentPageVosReference[0];
				initiateDisplayFunction();
			}
		}
		
		private function generateVoArray(maxIndex:int):Vector.<Object>
		{
			var voarray:Vector.<Object> = new Vector.<Object>;
			
			for (var i:int = currentIndex; i<maxIndex; i++)
			{
				var currentVO:Object = vos[i];
				voarray.push(currentVO);
			}	
			return voarray;
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
			myFormat.size = 16;  
			myFormat.italic = true;  
			tf.setTextFormat(myFormat);
			
			tfmc.x = (20*(pageNumber-1)) + currentImagesContainer.x;
			tfmc.y = currentImagesContainer.y - 40;
			tfmc.addChild(tf);
			tfmc.width = tf.width;
			tfmc.height = tf.height;
			tfmc.buttonMode = true
			addChild(tfmc);
		}
		
		private function navigateToPage(event:MouseEvent):void
		{
			var pageNumber:int = int(event.currentTarget.text); 
			if(pageNumber != currentPage)
			{
				currentPage = pageNumber;
				currentPageVosReference = pageVosReference[currentPage];
				
				VisualizerUtils.removeChildren(currentImagesContainer);
				
				if(currentPageVosReference[0].bmData)
					animateTiles();
				else
					loadPage();
			}
		}
		
		private function onLoadComplete(event:Event):void
		{
			compareImagesLoadedToImagesToLoad();
		}
		
		private function errorHandlerIOErrorEvent(event:IOErrorEvent):void
		{
			compareImagesLoadedToImagesToLoad();
		}
		
		private function compareImagesLoadedToImagesToLoad():void
		{
			imagesLoaded++;
			
			if (imagesLoaded == numberOfImagesToLoadNext)
			{
				storeBitmapData();
				imagesLoaded = 0;
				animateTiles();
			}
		}
		
		private function storeBitmapData():void
		{				
			for(var i:int = 0; i<numberOfImagesToLoadNext; i++)
			{
				if(imageLoaders[i] && imageLoaders[i].content)
				{
					var bitmap:Bitmap = imageLoaders[i].content as Bitmap;
					currentPageVosReference[i].bmData = bitmap.bitmapData;
				}
				else
					currentPageVosReference[i].bmData = VisualizerUtils.generateErrorBitmap(imageWidth, imageHeight);	
			}
		}
		
		protected function createLabel(imageNumber:int):TextField
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
			
			tf.x = ((imageWidth/2) - (tf.width/2));
			tf.y = ((imageHeight + 10));
			return tf;
		}
		
		protected function loadPage():void
		{	
			imageLoaders = new Vector.<Loader>;
			numberOfImagesToLoadNext = currentPageVosReference.length;
			
			for each(var vo:Object in currentPageVosReference)
			{
				if(vo.url)
				{
					var imageLoader:Loader = new Loader();
					var image:URLRequest = new URLRequest(VisualizerVanity.FashionArtsURL+vo.url);
					imageLoader.load(image);
					imageLoaders.push(imageLoader);
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandlerIOErrorEvent);
				}
				else
				{
					imagesLoaded++;
					imageLoaders.push(null);	
				}
			}
		}
		
		public function reAnimate(animateContentContainer:Boolean = true):void
		{
			VisualizerUtils.removeChildren(currentImagesContainer);
			animateTiles();
		}
		protected function assignCurrentSelected(current:Sprite):void
		{
			previouslySelected = currentSelected;
			currentSelected = currentImagesContainer.getChildIndex(current);
			
			if(previouslySelected != currentSelected)
			{
				previousVO = currentVO;
				currentVO = currentPageVosReference[currentSelected];
			}
		}
		
		//POTENTIALLY OVERIDDEN METHODS
		protected function imageOverHandler(event:MouseEvent):void
		{
			var filt:GlowFilter = new GlowFilter(0xff99cc, .5, 20, 20, 3, 2);  
			var filtArray:Array = [filt];
			
			var currentSprite:Sprite = event.currentTarget as Sprite;
			currentSprite.filters = filtArray; 
		}
		
		protected function imageOutHandler(event:MouseEvent):void
		{
			var currentSprite:Sprite = event.currentTarget as Sprite;
			currentSprite.filters = null; 
		}
		
		protected function imageDownHandler(event:MouseEvent):void{assignCurrentSelected(event.currentTarget as Sprite)};
		
		
		protected function animateTiles():void
		{
			var currentBitmapData:BitmapData;
			var currentBitmap:Bitmap;
			var currentImageHolder:Sprite;
			var imageNumber:int = 0;
			var currentY:int = 0;
			var numOfColumns:int = specifiedNumOfColumns;
			var numberOfImagesToAnimate:int = currentPageVosReference.length;
			
			for(var i:int = 1; i<=specifiedNumOfRows; i++)
			{
				currentY = ((i-1)*(totalHeight*scale));
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
					currentImageHolder.x = (a*(totalWidth * scale));
					currentImageHolder.y = currentY;
					currentImageHolder.buttonMode = true;
					currentBitmap.scaleX = scale;
					currentBitmap.scaleY = scale;
					currentImageHolder.addEventListener(MouseEvent.MOUSE_OVER, imageOverHandler);
					currentImageHolder.addEventListener(MouseEvent.MOUSE_OUT, imageOutHandler);
					currentImageHolder.addEventListener(MouseEvent.MOUSE_DOWN, imageDownHandler);
					currentImagesContainer.addChild(currentImageHolder);
					TweenLite.to(currentImageHolder,1, {alpha:1, delay:(.075*imageNumber)});
					imageNumber++;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}