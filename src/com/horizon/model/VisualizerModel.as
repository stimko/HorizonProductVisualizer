package com.horizon.model
{
	public class VisualizerModel
	{
		private var _surfacesVOsReference:Vector.<Object>;
		private var _surfacesXML:XML;
		private var _colorPickerVOsReference:Vector.<Vector.<Object>>=  new Vector.<Vector.<Object>>;
		private var _productsVOsReference:Vector.<Object>;
		private static var instance:VisualizerModel;
		private static var allowInstantiation:Boolean;
		
		public function VisualizerModel():void 
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use Model.getInstance() instead of new.");
			}
		}
		
		public function get surfacesXML():XML
		{
			return _surfacesXML;
		}

		public function set surfacesXML(value:XML):void
		{
			_surfacesXML = value;
		}

		public function get productsVOsReference():Vector.<Object>
		{
			return _productsVOsReference;
		}

		public function set productsVOsReference(value:Vector.<Object>):void
		{
			_productsVOsReference = value;
		}

		public function get colorPickerVOsReference():Vector.<Vector.<Object>>
		{
			return _colorPickerVOsReference;
		}

		public function set colorPickerVOsReference(value:Vector.<Vector.<Object>>):void
		{
			_colorPickerVOsReference = value;
		}

		public function get surfacesVOsReference():Vector.<Object>
		{
			return _surfacesVOsReference;
		}

		public function set surfacesVOsReference(value:Vector.<Object>):void
		{
			_surfacesVOsReference = value;
		}
		
		public static function getInstance():VisualizerModel 
		{
			if (instance == null) 
			{
				allowInstantiation = true;
				instance = new VisualizerModel();
				allowInstantiation = false;
			}
			return instance;
		}
	}
}