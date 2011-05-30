package com.horizon.model.vos
{
	import flash.display.BitmapData;

	public class ColorSwatchVO extends Object
	{
		private var _url:String;
		private var _hex:String;

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