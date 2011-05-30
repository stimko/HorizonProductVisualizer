package
{	
	import assets.swfs.ui.*;
	
	import com.adobe.images.JPGEncoder;
	import com.horizon.components.ColorPicker;
	import com.horizon.components.ProductsGallery;
	import com.horizon.components.SurfacesGallery;
	import com.horizon.model.VisualizerModel;
	import com.horizon.model.vos.SurfaceVO;
	import com.horizon.utils.VisualizerUtils;
	import com.horizon.utils.XmlUtil;
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
	
	import gs.TweenLite;
	
	[SWF(width='902', height='515', backgroundColor='#ffffff', frameRate='30')]
	
	public class HorizonProductVisualizer extends Sprite
	{
		private var surfacesGallery:Tiler;
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
		private var visualizerModel:VisualizerModel;
		
		private var swatchesXml:XML;
		private var surfacesXml:XML;
		private var productsXml:XML;
		private var xmlLoader:XmlUtil;
		
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
			visualizerModel = VisualizerModel.getInstance();
			initSurfacesGallery();
			addChild(contentHolder);
		}
		
		private function initSurfacesGallery():void
		{
				loadSurfacesXml('surfaces.xml');
		}
		
		private function initProductsGallery():void
		{
			if(!productsXml)
				loadProductsXml('clients.xml');
			else
				createProductsGallery();
		}
		
		private function displayTheProductsGallery():void
		{
			contentHolder.addChild(productsGallery);
			productsGallery.reAnimate();
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
				surfacesGallery = new SurfacesGallery(visualizerModel.surfacesVOsReference, false, true, 154, 125, 10, 10, 5, 1, 5, true);
				contentHolder.addChild(surfacesGallery);
				surfacesGallery.buttonMode = true;
				surfacesGallery.x = 45;
				surfacesGallery.y = 100;
			}
			else
			{
				contentHolder.addChild(surfacesGallery);	
				surfacesGallery.reAnimate();
			}
		}
		
		private function createProductsGallery():void
		{
			if(!productsGallery)
			{
				productsGallery = new ProductsGallery(visualizerModel.productsVOsReference,true, true, 154, 125, 3, 3, 3, 3, 0, false, .5);
				contentHolder.addChild(productsGallery);
				productsGallery.buttonMode = true;
/*				productsGallery.scaleX = .5;
				productsGallery.scaleY = .5;*/
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
		
		private function createColorSwatches():void
		{
			if(currentSurface != surfacesGallery.currentSelected)
			{				
				currentSurface = surfacesGallery.currentSelected;
				var currentSurfaceVOs:Vector.<Object> = visualizerModel.colorPickerVOsReference[currentSurface];
				
				colorSwatches = new ColorPicker(currentSurfaceVOs, false, false, 30, 30, 5, 5, 8, 1, 8, false);
				contentHolder.addChild(colorSwatches);
				colorSwatches.buttonMode = true;
				colorSwatches.x = 10;
				colorSwatches.y = 350;
			}
			else
			{
				colorSwatches.reAnimate();
				contentHolder.addChild(colorSwatches)
			}
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
					createSurfacesGallery();
					break;
				case "DesignAndDecorateButton":
					createColorSwatches();
					initProductsGallery();
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
		
		private function createPublishButtons():void
		{
			if(!savetodesktopButton){
				savetodesktopButton = new savetodesktopbutton();
				savetodesktopButton.buttonMode = true;
				savetodesktopButton.addEventListener(MouseEvent.CLICK, saveImage);
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
		
		private function saveImage(e:Object):void
		{
			//VisualizerUtils.saveimagetodesktop(canvas);
		}
		
		private function sendimagetofriend(e:Object):void
		{
			//VisualizerUtils.saveimagetofriend(canvas);
		}
		
		private function loadSurfacesXml(url:String):void
		{
			xmlLoader = new XmlUtil();
			xmlLoader.loadXml(url);
			xmlLoader.addEventListener(Event.COMPLETE, surfacesXmlLoaded);
		}
		
		private function surfacesXmlLoaded(event:Event):void{
			surfacesXml = xmlLoader.content;
			visualizerModel.surfacesVOsReference = xmlLoader.generateSurfacesVOsReference(surfacesXml);
			createSurfacesGallery();
			generateSwatchesXmlReference();
		}
		
		private function loadProductsXml(url:String):void
		{
			xmlLoader = new XmlUtil();
			xmlLoader.loadXml(url);
			xmlLoader.addEventListener(Event.COMPLETE, productsXmlLoaded);
		}
		
		private function productsXmlLoaded(event:Event):void
		{
			productsXml = xmlLoader.content;
			visualizerModel.productsVOsReference = xmlLoader.generateProductsVOsReference(productsXml);
			createProductsGallery();
		}
		
		private function generateSwatchesXmlReference():void
		{
			var surfacesLength:int = surfacesXml.surface.length();	
			
			for (var i:int = 0; i<surfacesLength; i++)
			{
				var item:XMLList = surfacesXml.surface[i].item;
				var newXML:XML = xmlLoader.convertXmlListToXML(item);
				var voVector:Vector.<Object> = xmlLoader.generateColorSwatchesVOsReference(newXML);
				
				visualizerModel.colorPickerVOsReference.push(voVector);
			}
		}
	}
}