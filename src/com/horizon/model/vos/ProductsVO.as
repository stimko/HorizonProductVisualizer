package com.horizon.model.vos
{
	import flash.display.BitmapData;
	
	public class ProductsVO extends Object
	{
		private var _url:String;
		private var _size:String;
		private var _bmData:BitmapData;

		public function get bmData():BitmapData
		{
			return _bmData;
		}

		public function set bmData(value:BitmapData):void
		{
			_bmData = value;
		}

		public function get size():String
		{
			return _size;
		}

		public function set size(value:String):void
		{
			_size = value;
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}
	}
}