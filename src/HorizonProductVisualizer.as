package
{	
	import assets.swfs.ui.*;
	
	import com.horizon.components.ColorPicker;
	import com.horizon.components.ProductsGallery;
	import com.horizon.components.SurfacesGallery;
	import com.horizon.events.ColorSwatchEvent;
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
	
	[SWF(width='900', height='515', backgroundColor='#ffffff', frameRate='25')]
	
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
		private var sendPopUp:sendToFriendPopUp;
		private var emailMessageSprite:InvalidEmail;
		private var xmlUtil:XmlUtil = new XmlUtil();
		private var preLoader:LoadingText;
		
		public function HorizonProductVisualizer()
		{
			stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
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
			currentState = VisualizerVanity.SURFACES;
			addChild(contentHolder);
			createNextButton();
			initSurfacesGallery();
		}
		
		private function addEventListeners():void
		{
			addEventListener(ColorSwatchEvent.MASK_READY, onMaskReady);
			addEventListener('newSurfaceSelected', onSurfaceSelected);
			xmlUtil.addEventListener('surfacesXMLLoaded', createSurfacesGallery);
			xmlUtil.addEventListener('productsXMLLoaded', createDesignView);
		}
		
		private function initSurfacesGallery():void{xmlUtil.loadSurfacesXml(VisualizerVanity.FashionArtsURL+'visualizer.php?view=surfaces')}
		
		private function initProductsGallery():void
		{
			if(!visualizerModel.productsXml)
				xmlUtil.loadProductsXml(VisualizerVanity.FashionArtsURL+'visualizer.php?view=products');
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
				if(!sendtofriendButton.hasEventListener(MouseEvent.CLICK))
					sendtofriendButton.addEventListener(MouseEvent.CLICK, displayEmailPopUp);
				animateContentContainer = false;
				emailMessageSprite.emailMessage.text = "";
			}
			else
				animateContentContainer = true;
			
			currentState == VisualizerVanity.PUBLISH ? nextButton.visible = false : 
				(nextButton.visible ? nextButton.visible  = true 
					: VisualizerUtils.fadeSpriteIn(nextButton));
			
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
					createEmailMessage();
					VisualizerUtils.fadeSpriteIn(contentHolder);
					break; 
			}
		}
		
		private function displayTheProductsGallery():void
		{
			contentHolder.addChild(productsFrame);
			contentHolder.addChild(productsGallery);
			productsGallery.reAnimate(animateContentContainer);
		}
		
		private function displayCroppedCanvas():void
		{
			croppedCanvas = VisualizerUtils.captureCreationArea(colorSwatches, productsGallery);
			addChild(croppedCanvas);
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
			nextButton.x = 789;
			nextButton.y  = 446;
			nextButton.buttonMode = true;
			addChild(nextButton);
			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, nextDown);
			addGenericListenersToButton(nextButton);
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
				savetodesktopButton.y = 100;
				savetodesktopButton.x = 500;
				savetodesktopButton.buttonMode = true;
				savetodesktopButton.addEventListener(MouseEvent.CLICK, saveImage);
				addGenericListenersToButton(savetodesktopButton);
				
			}
			contentHolder.addChild(savetodesktopButton);
			
			if(!sendtofriendButton)
			{
				sendtofriendButton = new sendtofriendbutton();
				sendtofriendButton.y = 150;
				sendtofriendButton.x = 500;
				sendtofriendButton.buttonMode = true;
				sendtofriendButton.addEventListener(MouseEvent.CLICK, displayEmailPopUp);
				addGenericListenersToButton(sendtofriendButton);
			}
			contentHolder.addChild(sendtofriendButton);
			
			if(!printButton)
			{
				printButton = new assets.swfs.ui.printButton;	
				printButton.x = 500;
				printButton.y = 200;
				printButton.buttonMode = true;
				printButton.addEventListener(MouseEvent.CLICK, printTheCreation);
				addGenericListenersToButton(printButton);
			}
			contentHolder.addChild(printButton);
		}
		
		private function createEmailMessage():void
		{
			emailMessageSprite = new InvalidEmail();
			contentHolder.addChild(emailMessageSprite);
			emailMessageSprite.x = 500;
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
				surfacesGallery = new SurfacesGallery(visualizerModel.surfacesVOsReference, false, true, 150, 170, 10, 10, 5, 1, 5, true, 1, 50, 160, true);
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
				productsGallery = new ProductsGallery(visualizerModel.productsVOsReference, true, true, 96, 96, 18, 18, 5, 5, 0, false, .5, 515, 110);
				contentHolder.addChild(productsFrame);
				contentHolder.addChild(productsGallery);
				productsGallery.buttonMode = true;
			}
			else
				displayTheProductsGallery();
			
			VisualizerUtils.fadeSpriteIn(productsFrame);
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
			colorSwatches = new ColorPicker(currentSurfaceVOs, false, false, 25, 25, 5, 5, 0, 1, 8, false, 1, 12, 456);
			contentHolder.addChild(colorSwatches);
		}
		
		private function setProductsIndex():void{contentHolder.swapChildren(productsGallery, colorSwatches)}
		
		//PUBLISHING UTILS
		private function saveImage(e:Object):void{VisualizerUtils.saveimagetodesktop(croppedCanvas)}
		private function displayEmailPopUp(e:Object):void{
			if(!sendPopUp)
			{
				sendPopUp = new sendToFriendPopUp();
				sendPopUp.x = 502;
				sendPopUp.y = printButton.y + printButton.height + 15;
				sendPopUp.sendButton.buttonMode=true;
				sendPopUp.cancelButton.addEventListener(MouseEvent.CLICK, closePopUp);
				sendPopUp.cancelButton.buttonMode=true;
				addGenericListenersToButton(sendPopUp.cancelButton);
				addGenericListenersToButton(sendPopUp.sendButton);
			}
			
			emailMessageSprite.emailMessage.text = "";
			sendtofriendButton.removeEventListener(MouseEvent.CLICK, displayEmailPopUp);
			VisualizerUtils.fadeSpriteIn(sendPopUp);
			
			if(!sendPopUp.sendButton.hasEventListener(MouseEvent.CLICK))
				sendPopUp.sendButton.addEventListener(MouseEvent.CLICK, sendimage);
			
			setChildIndex(contentHolder, numChildren-1);
			contentHolder.addChild(sendPopUp);
		}
		private function printTheCreation(e:Object):void{VisualizerUtils.printCanvas(croppedCanvas)}
		
		//Send Pop Up Listeners
		private function sendimage(event:MouseEvent):void
		{
			var emailText:String = sendPopUp.emailToInput.text;
			var nameText:String = sendPopUp.nameInput.text;
			var fromEmail:String = sendPopUp.emailFromInput.text;
			
			if(VisualizerUtils.validateEmail(emailText, nameText, fromEmail))
			{
				closePopUp(null);
				emailMessageSprite.y = printButton.y + printButton.height + 15;
				sendPopUp.sendButton.removeEventListener(MouseEvent.CLICK, sendimage);
				emailMessageSprite.emailMessage.text = VisualizerVanity.EMAIL_SUCCESS_MESSAGE;
				VisualizerUtils.sendimagetofriend(croppedCanvas, 
					sendPopUp.emailToInput.text, 
					sendPopUp.nameInput.text, 
					sendPopUp.emailFromInput.text);
			} else
			{
				emailMessageSprite.y = sendPopUp.y + sendPopUp.height + 5;
				emailMessageSprite.emailMessage.text = VisualizerVanity.EMAIL_ERROR_MESSAGE;
				VisualizerUtils.fadeSpriteIn(emailMessageSprite);
			}
		}
		
		private function closePopUp(event:MouseEvent):void
		{
			contentHolder.removeChild(sendPopUp);
			sendtofriendButton.addEventListener(MouseEvent.CLICK, displayEmailPopUp);
			emailMessageSprite.emailMessage.text = "";
		}
		//DISPLAY
		private function createProductsFrame():void
		{
			productsFrame = VisualizerUtils.loadFrameImage();
			productsFrame.x = 480;
			productsFrame.y = 73;
		}
		
		//EVENT TRANSFER
		private function onMaskReady(event:ColorSwatchEvent):void
		{
			var csEvent:ColorSwatchEvent = new ColorSwatchEvent(event.maskSprite, event.type);
			productsGallery.dispatchEvent(csEvent);
		}
		//GENERIC MOUSE LISTENERS
		private function addGenericListenersToButton(mc:MovieClip):void
		{
			mc.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			mc.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		private function mouseOver(event:MouseEvent):void
		{
			event.currentTarget.gotoAndStop('over');
		}
		
		private function mouseOut(event:MouseEvent):void
		{
			event.currentTarget.gotoAndStop('out');
		}
	}
}