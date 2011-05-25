package
{	
	import assets.swfs.ui.*;
	
	import com.adobe.images.JPGEncoder;
	import com.sigmagroup.components.AssetLoader;
	import com.sigmagroup.components.Tiler;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.xml.XMLNode;
	
	[SWF(width='902', height='515', backgroundColor='#ffffff', frameRate='30')]
	
	public class HorizonProductVisualizer extends Sprite
	{
		private var surfacesGallery:SurfacesGallery;
		private var productsGallery:Tiler;
		private var colorSwatches:Tiler;
		private var bitmapContainer:Sprite;
		private var currentStateButton:MovieClip;
		private var contentHolder:Sprite;
		private var shellmc:mainshell;
		private var savetodesktopButton:savetodesktopbutton;
		private var sendtofriendButton:sendtofriendbutton;
		private var snapshotBitmapData:BitmapData;
		private var urlVars:URLVariables;
		private var cBox:ComboBox = new ComboBox();
		
		private var swatchesXml:XML;
		private var surfacesXml:XML;
		private var productsXml:XML;
		private var xmlLoader:XmlLoader;
		
		private var currentSurface:int = -1;
		private var colorSwatchesXmlReference:Array = new Array();
		
		public function HorizonProductVisualizer()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE))removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			shellmc = new mainshell();
			contentHolder = new Sprite();
			addChild(shellmc);
			assignMainButtonHandlers();
			assignCurrentButton(shellmc.buttons.SelectASurfaceButton);
			initSurfacesGallery();
			addChild(contentHolder);
		}
		
		private function tilesReadyHandler(event:Event):void
		{
			productsGallery.currentImagesContainer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function initProductsGallery():void
		{
			if(!productsXml)
				loadProductsXml('clients.xml');
			else
				createProductsGallery();
		}
		
		private function initSurfacesGallery():void
		{
			if(!surfacesXml)
				loadSurfacesXml('surfaces.xml');
			else
				createSurfacesGallery();
		}
		
		private function createProductsGallery():void
		{
			if(!productsGallery)
			{
				productsGallery = new ProductsGallery(productsXml, true, true, 154, 125, 3, 3, 3, 3, 0, false);
				productsGallery.addEventListener(Event.COMPLETE, tilesReadyHandler);
				contentHolder.addChild(productsGallery);
				productsGallery.buttonMode = true;
				productsGallery.scaleX = .5;
				productsGallery.scaleY = .5;
				productsGallery.x = 600;
				productsGallery.y = 100;
				
/*				var dummyarray:Array = ['hello', 'hi', 'shark'];
				var dp:DataProvider = new DataProvider(dummyarray);
				cBox.dataProvider = dp;
				cBox.x = 200;
				cBox.y = 200;
				cBox.addEventListener(Event.CHANGE, displayDifferentCategory);
				contentHolder.addChild(cBox);*/
			}
			else
				displayTheProductsGallery();	
		}
		
		private function displayTheProductsGallery():void
		{
			contentHolder.addChild(productsGallery);
			//contentHolder.addChild(cBox);
		}
		
		private function displayDifferentCategory(event:Event):void
		{
			trace(event.currentTarget.selectedIndex);
			
		}
		
		private function createSurfacesGallery():void
		{
			if(!surfacesGallery)
			{
				surfacesGallery = new SurfacesGallery(surfacesXml, false, true, 154, 125, 10, 10, 5, 1, 5, true);
				contentHolder.addChild(surfacesGallery);
				surfacesGallery.buttonMode = true;
				surfacesGallery.x = 45;
				surfacesGallery.y = 100;
			}
			else
				contentHolder.addChild(surfacesGallery);	
		}
		
		private function createColorSwatches():void
		{
			if(currentSurface != surfacesGallery.currentSurface)
			{				
				currentSurface = surfacesGallery.currentSurface
				var currentSurfaceXML:XML = colorSwatchesXmlReference[currentSurface];
				
				colorSwatches = new ColorPicker(currentSurfaceXML, false, false, 30, 30, 5, 5, 8, 1, 8, false);
				//colorSwatches.addEventListener(Event.COMPLETE, tilesReadyHandler);
				contentHolder.addChild(colorSwatches);
				colorSwatches.buttonMode = true;
				colorSwatches.x = 10;
				colorSwatches.y = 350;
			}
			else
				contentHolder.addChild(colorSwatches)
		}
		
		private function assignMainButtonHandlers():void
		{
			var shellButtons:MovieClip = shellmc.buttons as MovieClip;
			var numButtons:int = shellButtons.numChildren;
			for(var i:int = 0; i<numButtons; i++)
			{
				var currentButton:MovieClip = shellButtons.getChildAt(i) as MovieClip;
				currentButton.buttonMode = true;
				currentButton.addEventListener(MouseEvent.MOUSE_OVER, stepButtonOverHandler);
				currentButton.addEventListener(MouseEvent.MOUSE_OUT, stepButtonOutHandler);
				currentButton.addEventListener(MouseEvent.MOUSE_DOWN, stepButtonDownHandler); 
			}
		}
		
		private function stepButtonOverHandler(event:MouseEvent):void
		{
			event.currentTarget.gotoAndStop('down');
		}
		
		private function stepButtonOutHandler(event:MouseEvent):void
		{
			event.currentTarget.gotoAndStop('up');
		}
		
		private function stepButtonDownHandler(event:MouseEvent):void
		{
			reConfigurePreviousButton();
			
			assignCurrentButton(event.currentTarget as MovieClip);
			
			displayPageContent(currentStateButton.name);
		}
		
		private function displayPageContent(name:String):void
		{
			removeChild(contentHolder);
			contentHolder = new Sprite();
			
			switch(name){
				case "SelectASurfaceButton":
					initSurfacesGallery();
					break;
				case "DesignAndDecorateButton":
					initProductsGallery();
					createColorSwatches();
					break;
				case "SaveAndShareButton":
					createPublishButtons();	
					break; 
			}
			addChild(contentHolder);
		}
		
		private function reConfigurePreviousButton():void
		{
			currentStateButton.gotoAndStop('up');
			currentStateButton.addEventListener(MouseEvent.MOUSE_OVER, stepButtonOverHandler);
			currentStateButton.addEventListener(MouseEvent.MOUSE_OUT, stepButtonOutHandler);
			currentStateButton.addEventListener(MouseEvent.MOUSE_DOWN, stepButtonDownHandler); 
		}
		
		private function assignCurrentButton(button:MovieClip):void
		{
			currentStateButton = button ;
			currentStateButton.gotoAndStop('down');
			
			currentStateButton.removeEventListener(MouseEvent.MOUSE_OVER, stepButtonOverHandler);
			currentStateButton.removeEventListener(MouseEvent.MOUSE_OUT, stepButtonOutHandler);
			currentStateButton.removeEventListener(MouseEvent.MOUSE_DOWN, stepButtonDownHandler); 
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			var localMouseX:int = event.target.mouseX;
			var localMouseY:int = event.target.mouseY;
			var ratio:Number = getRatio(event.target as Sprite);
			
			var copyBitmap:Bitmap = copyBitmapData(event.target.getChildAt(0));
			copyBitmap.smoothing = true;
			
			bitmapContainer = new Sprite();
			bitmapContainer.addChild(copyBitmap);
			bitmapContainer.startDrag();
			bitmapContainer.scaleX = bitmapContainer.scaleY = ratio;
			bitmapContainer.x = mouseX - (localMouseX * ratio);
			bitmapContainer.y = mouseY - (localMouseY * ratio);
			addChild(bitmapContainer);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			bitmapContainer.addEventListener(MouseEvent.MOUSE_DOWN, moveProduct);
			bitmapContainer.stopDrag();
			bitmapContainer.buttonMode = true;
		}
		
		private function moveProduct(event:MouseEvent):void
		{
			event.currentTarget.startDrag();
			event.currentTarget.addEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
		}
		
		private function ceaseDraggage(event:MouseEvent):void
		{
			event.currentTarget.stopDrag();	
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP, ceaseDraggage);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(event.stageX<0 || event.stageX>stage.stageWidth || event.stageY<0 || event.stageY>stage.stageHeight){
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				bitmapContainer.stopDrag();
				removeChild(bitmapContainer);
			}
		}
		
		private function createPublishButtons():void
		{
			if(!savetodesktopButton){
				savetodesktopButton = new savetodesktopbutton();
				savetodesktopButton.buttonMode = true;
				savetodesktopButton.addEventListener(MouseEvent.CLICK, saveimagetodesktop);
				contentHolder.addChild(savetodesktopButton);
			}
			else
				contentHolder.addChild(savetodesktopButton);
			
			if(!sendtofriendButton)
			{
				sendtofriendButton = new sendtofriendbutton();
				sendtofriendButton.y = 50;
				sendtofriendButton.addEventListener(MouseEvent.CLICK, sendimagetofriend);
				contentHolder.addChild(sendtofriendButton);
			}
			else
				contentHolder.addChild(sendtofriendButton);
		}
		
		//UTILS//
		private function saveimagetodesktop(e:Object):void
		{
			snapshotBitmapData = new BitmapData(500, 500);
			snapshotBitmapData.draw(stage);
			
			var fileRef:FileReference = new FileReference();
			var encoder:JPGEncoder = new JPGEncoder();
			var ba:ByteArray = encoder.encode(snapshotBitmapData);
			fileRef.save(ba,"capture.jpg");
		}
		
		private function sendimagetofriend(e:Object):void
		{
			//addChild(tiler);
			snapshotBitmapData = new BitmapData(500, 500);
			snapshotBitmapData.draw(stage);
			
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
		
		private function copyBitmapData(bitmap:Bitmap):Bitmap
		{
			var copyBitmapData:BitmapData = bitmap.bitmapData;	
			var copyBitmap:Bitmap = new Bitmap(copyBitmapData);
			
			return copyBitmap;
		}
		
		private function getRatio(bmc:Sprite):Number
		{
			var ratio:Number;
			var imageIndex:int = productsGallery.currentImagesContainer.getChildIndex(bmc);
			var size:String = productsGallery.getSize(imageIndex);
			
			switch(size)
			{
				case 'small':
					ratio = .5;
					break;
				case 'medium':
					ratio = .75;
					break;
				case 'large':
					ratio =  1;
					break;
			}
			return ratio;
		}
		
		private function loadSurfacesXml(url:String):void
		{
			xmlLoader = new XmlLoader(url);
			xmlLoader.addEventListener(Event.COMPLETE, surfacesXmlLoaded);
		}
		
		private function surfacesXmlLoaded(event:Event):void{
			surfacesXml = xmlLoader.content;
			createSurfacesGallery();
			generateSwatchesXmlReference();
		}
		
		private function loadProductsXml(url:String):void
		{
			xmlLoader = new XmlLoader(url);
			xmlLoader.addEventListener(Event.COMPLETE, productsXmlLoaded);
		}
		
		private function productsXmlLoaded(event:Event):void
		{
			productsXml = xmlLoader.content;
			createProductsGallery();
		}
		
		private function generateSwatchesXmlReference():void
		{
			var surfacesLength:int = surfacesXml.surface.length();	
			
			for (var i:int = 0; i<surfacesLength; i++)
			{
				var item:XMLList = surfacesXml.surface[i].item;
				var xmlString:String =item.toXMLString();
				xmlString = '<items>' + xmlString + '</items>';
				var newXML:XML = new XML(xmlString);
				
				colorSwatchesXmlReference.push(newXML);
			}
		}
	}
}