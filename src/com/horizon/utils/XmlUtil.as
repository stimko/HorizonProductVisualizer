package com.horizon.utils
{
	import com.horizon.model.VisualizerModel;
	import com.horizon.model.vos.ColorSwatchVO;
	import com.horizon.model.vos.ProductsVO;
	import com.horizon.model.vos.SurfaceVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XmlUtil extends EventDispatcher
	{
		public var content:XML;
		private var visualizerModel:VisualizerModel = VisualizerModel.getInstance();
		private var loader:URLLoader;
				
		public function loadXml(sourceUrl:String):void
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			loader.load(new URLRequest(sourceUrl));
		}
		
		private function xmlLoaded(event:Event):void
		{
			content = new XML(event.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function convertXmlListToXML(xmlList:XMLList):XML
		{
			var xmlString:String = xmlList.toXMLString();
			xmlString = '<items>' + xmlString + '</items>';
			var newXML:XML = new XML(xmlString);
			return newXML;
		}
		
		public function generateSurfacesVOsReference(xml:XML):Vector.<Object>
		{
			var voarray:Vector.<Object> = new Vector.<Object>;
			var xmlLength:int = xml.surface.length();
			
			for (var i:int = 0; i<xmlLength; i++)
			{
				var sVO:Object = new SurfaceVO();
				//vo.url = String(theXML.surface[i].item[0].@imagesrc);
				sVO.url = xml.surface[i].@thumb;
				sVO.displayName = xml.surface[i].@name;
				voarray.push(sVO);
			}	
			return voarray;
		}
		
		public function generateColorSwatchesVOsReference(xml:XML):Vector.<Object>
		{
			var voarray:Vector.<Object> = new Vector.<Object>;
			var xmlLength:int = xml.item.length();
			
			for (var i:int = 0; i<xmlLength; i++)
			{
				var csVO:Object = new ColorSwatchVO();
				csVO.url = xml.item[i].@imagesrc;
				//csVO.url = 'assets/images/clients/brut.jpg';
				csVO.hex = xml.item[i].@hex;
				voarray.push(csVO);
			}	
			return voarray;
		}
		
		public function generateProductsVOsReference(xml:XML):Vector.<Object>
		{
			var voarray:Vector.<Object> = new Vector.<Object>;
			var xmlLength:int = xml.product.length();
			
			for (var i:int = 0; i<xmlLength; i++)
			{
				var pVO:Object = new ProductsVO();
				//pVO.url = 'http://fashionartstage.sigmagroup.com/'+xml.product[i].@imagesrc;
				pVO.url = xml.product[i].@imagesrc;
				pVO.size = xml.product[i].@size;
				voarray.push(pVO);
			}	
			return voarray;
		}
		
		public function loadSurfacesXml(url:String):void
		{
			loadXml(url);
			addEventListener(Event.COMPLETE, surfacesXmlLoaded);
		}
		private function surfacesXmlLoaded(event:Event):void
		{
			removeEventListener(Event.COMPLETE, surfacesXmlLoaded);
			visualizerModel.surfacesXml = content;
			visualizerModel.surfacesVOsReference = generateSurfacesVOsReference(visualizerModel.surfacesXml);
			dispatchEvent(new Event('surfacesXMLLoaded'));
			generateSwatchesVosReference();
		}
		
		public function loadProductsXml(url:String):void
		{
			loadXml(url);
			addEventListener(Event.COMPLETE, productsXmlLoaded);
		}
		
		private function productsXmlLoaded(event:Event):void
		{
			removeEventListener(Event.COMPLETE, productsXmlLoaded)
			visualizerModel.productsXml = content;
			visualizerModel.productsVOsReference = generateProductsVOsReference(visualizerModel.productsXml);
			dispatchEvent(new Event('productsXMLLoaded'));
		}		
		
		private function generateSwatchesVosReference():void
		{
			var surfacesLength:int = visualizerModel.surfacesXml.surface.length();	
			
			for (var i:int = 0; i<surfacesLength; i++)
			{
				var item:XMLList = visualizerModel.surfacesXml.surface[i].item;
				var newXML:XML = convertXmlListToXML(item);
				var voVector:Vector.<Object> = generateColorSwatchesVOsReference(newXML);
				
				visualizerModel.colorPickerVOsReference.push(voVector);
			}
		}
	}
}