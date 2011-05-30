package com.horizon.utils
{
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
				
		public function loadXml(sourceUrl:String):void
		{
			var loader:URLLoader = new URLLoader();
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
				sVO.url = 'assets/images/clients/brut.jpg';
				sVO.displayName = String(xml.surface[i].@name);
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
				//vo.url = String(theXML.surface[i].item[0].@imagesrc);
				csVO.url = 'assets/images/clients/brut.jpg';
				csVO.hex = xml.item[i].@hex;
				voarray.push(csVO);
			}	
			return voarray;
		}
		
		public function generateProductsVOsReference(xml:XML):Vector.<Object>
		{
			var voarray:Vector.<Object> = new Vector.<Object>;
			var xmlLength:int = xml.client.length();
			
			for (var i:int = 0; i<xmlLength; i++)
			{
				var pVO:Object = new ProductsVO();
				pVO.url = xml.client[i].@imageurl;
				pVO.size = xml.client[i].@size;
				voarray.push(pVO);
			}	
			return voarray;
		}
	}
}