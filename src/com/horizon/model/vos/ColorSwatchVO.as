package com.horizon.model.vos
{
	import flash.display.BitmapData;

	public class ColorSwatchVO extends Object
	{
		private var _url:String;
		private var _hex:String;
		private var _bmData:BitmapData;

		public function get bmData():BitmapData
		{
			return _bmData;
		}

		public function set bmData(value:BitmapData):void
		{
			_bmData = value;
		}

		public function get hex():String
		{
			return _hex;
		}

		public function set hex(value:String):void
		{
			_hex = value;
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