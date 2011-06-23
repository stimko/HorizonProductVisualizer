package
{	
	import assets.swfs.ui.*;
	
	import com.horizon.components.ColorPicker;
	import com.horizon.components.ProductsGallery;
	import com.horizon.components.SurfacesGallery;
	import com.horizon.events.ColorSwatchEvent;
	import com.horizon.events.ProductEvent;
	import com.horizon.events.TilerEvent;
	import com.horizon.model.VisualizerModel;
	import com.horizon.utils.VisualizerUtils;
	import com.horizon.utils.VisualizerVanity;
	import com.horizon.utils.XmlUtil;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	[SWF(width='902', height='515', backgroundColor='#ffffff', frameRate='25')]
	
	public class HorizonProductVisualizer extends Sprite
	{
		private var surfacesGallery:Tiler;
		private var productsGallery:Tiler;
		private var colorSwatches:Tiler;
		private var currentStateButton:MovieClip;
		private var contentHolder:Sprite = new Sprite();
		private var shellmc:mainshell;
		private var savetodesktopButton:savetodesktopbutton;
		private var sendtofriendButton:sendtofriendbutton;
		private var snapshotBitmapData:BitmapData;
		//private var cBox:ComboBox = new ComboBox();
		private var visualizerModel:VisualizerModel;
		private var productsFrame:Loader;
		private var shellButtons:Sprite;
		private var nextButton:assets.swfs.ui.nextButton;
		private var currentState:String;
		private var previousState:String;
		private var croppedCanvas:Bitmap;
		private var animateContentContainer:Boolean;
		private var currentSurface:int = 0;
		private var printButton:assets.swfs.ui.printButton;
		private var xmlUtil:XmlUtil = new XmlUtil();
		
		public function HorizonProductVisualizer()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		//INITIALIZATION
		private function init():void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE))removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			displayShell();
			addEventListeners();
			assignMainButtonHandlers();
			assignCurrentButton(shellmc.buttons.SelectASurface);
			visualizerModel = VisualizerModel.getInstance();
			initSurfacesGallery();
			currentState = VisualizerVanity.SURFACES;
			addChild(contentHolder);
			createNextButton();
		}
		
		private function addEventListeners():void
		{
			addEventListener(ColorSwatchEvent.MASK_READY, onMaskReady);
			addEventListener('newSurfaceSelected', onSurfaceSelected);
			xmlUtil.addEventListener('surfacesXMLLoaded', createSurfacesGallery);
			xmlUtil.addEventListener('productsXMLLoaded', createDesignView);
		}
		
		private function initSurfacesGallery():void{xmlUtil.loadSurfacesXml('surfaces.xml')}
		
		private function initProductsGallery():void
		{
			if(!visualizerModel.productsXml)
				xmlUtil.loadProductsXml('products.xml');
			else
			{
				createProductsGallery();
				createColorSwatches();
			}
		}
		//NAVIGATING STATE CHANGES
		private function displayPageContent(name:String):void
		{
			VisualizerUtils.removeChildren(contentHolder);
			
			previousState = currentState;
			currentState = name;
			
			if(previousState == VisualizerVanity.PUBLISH)
			{
				removeChild(croppedCanvas);
				animateContentContainer = false;
			}
			else
				animateContentContainer = true;
			
			currentState == VisualizerVanity.PUBLISH ? nextButton.visible = false : nextButton.visible = true;
			
			switch(name){
				case VisualizerVanity.SURFACES:
					createSurfacesGallery();
					break;
				case VisualizerVanity.DESIGN:
					initProductsGallery();
					break;
				case VisualizerVanity.PUBLISH:
					displayCroppedCanvas();
					createPublishButtons();
					animateContentHolder();
					break; 
			}
		}
		
		private function displayTheProductsGallery():void
		{
			contentHolder.addChild(productsFrame);
			contentHolder.addChild(productsGallery);
			productsGallery.reAnimate(animateContentContainer);
			//contentHolder.addChild(cBox);
		}
		
		/*		private function displayDifferentCategory(event:Event):void
		{
		trace(event.currentTarget.selectedIndex);
		}*/
		
		private function displayCroppedCanvas():void
		{
			croppedCanvas = VisualizerUtils.captureCreationArea(colorSwatches, productsGallery);
			addChild(croppedCanvas);
		}
		
		private function animateContentHolder():void
		{
			contentHolder.alpha = 0;
			TweenLite.to(contentHolder,.5, {alpha:1});
		}
		
		private function createDesignView(event:Object):void
		{
			createProductsFrame();
			createProductsGallery();
			createColorSwatches();
			enablePublishButton();
		}
		//SHELL AND BUTTONS
		private function displayShell():void
		{
			shellmc = new mainshell();
			addChild(shellmc);
		}
		
		private function assignMainButtonHandlers():void
		{
			shellButtons = shellmc.buttons as Sprite;
			var numButtons:int = shellButtons.numChildren - 1;
			for(var i:int = 0; i<numButtons; i++)
			{
				var currentButton:MovieClip = shellButtons.getChildAt(i) as MovieClip;
				configShellButton(currentButton);
			}
		}
		
		private function createNextButton():void
		{
			this.nextButton = new assets.swfs.ui.nextButton();
			nextButton.x = 775;
			nextButton.y  = 450;
			addChild(nextButton);
			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, nextDown);
		}
		
		private function nextDown(event:Object):void
		{
			reConfigurePreviousButton();
			if(currentState == VisualizerVanity.SURFACES)
			{
				assignCurrentButton(shellButtons[VisualizerVanity.DESIGN]);
				displayPageContent(VisualizerVanity.DESIGN);
			}
			else if(currentState == VisualizerVanity.DESIGN)
			{
				assignCurrentButton(shellButtons[VisualizerVanity.PUBLISH]);
				displayPageContent(VisualizerVanity.PUBLISH);
			}
		}
		
		private function configShellButton(currentButton:MovieClip):void
		{
			currentButton.buttonMode = true;
			currentButton.addEventListener(MouseEvent.MOUSE_OVER, stepButtonOverHandler);
			currentButton.addEventListener(MouseEvent.MOUSE_OUT, stepButtonOutHandler);
			currentButton.addEventListener(MouseEvent.MOUSE_DOWN, stepButtonDownHandler); 
		}
		
		private function stepButtonDownHandler(event:MouseEvent):void
		{
			reConfigurePreviousButton();
			assignCurrentButton(event.currentTarget as MovieClip);
			displayPageContent(currentStateButton.name);
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
				savetodesktopButton.y = 150;
				savetodesktopButton.x = 500;
				savetodesktopButton.buttonMode = true;
				savetodesktopButton.addEventListener(MouseEvent.CLICK, saveImage);
			}
			contentHolder.addChild(savetodesktopButton);
			
			if(!sendtofriendButton)
			{
				sendtofriendButton = new sendtofriendbutton();
				sendtofriendButton.y = 200;
				sendtofriendButton.x = 500;
				sendtofriendButton.addEventListener(MouseEvent.CLICK, sendimagetofriend);
			}
			contentHolder.addChild(sendtofriendButton);
			
			if(!printButton)
			{
				printButton = new assets.swfs.ui.printButton;	
				printButton.x = 500;
				printButton.y = 250;
				printButton.addEventListener(MouseEvent.CLICK, printTheCreation);
			}
			contentHolder.addChild(printButton);
		}
		
		private function enablePublishButton():void
		{
			var currentButton:MovieClip = shellButtons.getChildByName(VisualizerVanity.PUBLISH) as MovieClip;
			this.configShellButton(currentButton);
		}
		
		private function onSurfaceSelected(event:Event):void
		{
			reConfigurePreviousButton();
			assignCurrentButton(shellButtons[VisualizerVanity.DESIGN]);
			displayPageContent(VisualizerVanity.DESIGN);
		}
		
		private function stepButtonOverHandler(event:MouseEvent):void{event.currentTarget.gotoAndStop('down')}
		private function stepButtonOutHandler(event:MouseEvent):void{event.currentTarget.gotoAndStop('up')}
		//COMPONENT CREATION
		private function createSurfacesGallery(event:Object=null):void
		{
			if(!surfacesGallery)
			{
				surfacesGallery = new SurfacesGallery(visualizerModel.surfacesVOsReference, false, true, 150, 170, 10, 10, 5, 1, 5, true, 1, 30, 75);
				contentHolder.addChild(surfacesGallery);
				surfacesGallery.buttonMode = true;
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
				productsGallery = new ProductsGallery(visualizerModel.productsVOsReference,true, true, 96, 96, 5, 5, 3, 3, 0, false, 1, 500, 100);
				contentHolder.addChild(productsFrame);
				contentHolder.addChild(productsGallery);
				productsGallery.buttonMode = true;
				
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
			var currentVOs:Vector.<Object> = visualizerModel.colorPickerVOsReference[surfacesGallery.currentSelected];
			
			if(!colorSwatches)
			{
				instantiateColorSwatchComponent(currentVOs);
				currentSurface = surfacesGallery.currentSelected;
				setProductsIndex();
				return;
			}
			
			if(currentSurface != surfacesGallery.currentSelected)
			{	
				productsGallery.dispatchEvent(new TilerEvent(TilerEvent.CLEANUP_CONTENT));
				colorSwatches.dispatchEvent(new TilerEvent(TilerEvent.REPOPULATE, false, false, currentVOs));
				currentSurface = surfacesGallery.currentSelected;
			}
			else
				colorSwatches.reAnimate(animateContentContainer);
			
			contentHolder.addChild(colorSwatches);
			setProductsIndex();
		}
		
		private function instantiateColorSwatchComponent(currentSurfaceVOs:Vector.<Object>):void
		{
			colorSwatches = new ColorPicker(currentSurfaceVOs, false, false, 25, 25, 5, 5, 0, 1, 8, false, 1, 20, 500);
			contentHolder.addChild(colorSwatches);
		}
		
		private function setProductsIndex():void{contentHolder.swapChildren(productsGallery, colorSwatches)}
		
		//PUBLISHING UTILS
		private function saveImage(e:Object):void{VisualizerUtils.saveimagetodesktop(croppedCanvas)}
		private function sendimagetofriend(e:Object):void{VisualizerUtils.sendimagetofriend(croppedCanvas)}
		private function printTheCreation(e:Object):void{VisualizerUtils.printCanvas(croppedCanvas)}
		
		//DISPLAY
		private function createProductsFrame():void
		{
			productsFrame = VisualizerUtils.loadFrameImage();
			productsFrame.x = 500;
			productsFrame.y = 100;
		}
		//EVENT TRANSFER
		private function onMaskReady(event:ColorSwatchEvent):void
		{
			var csEvent:ColorSwatchEvent = new ColorSwatchEvent(event.maskSprite, event.type);
			productsGallery.dispatchEvent(csEvent);
		}
	}
}