package com.horizon.model.vos
{
	import flash.display.BitmapData;

	public class SurfaceVO extends Object
	{
		private var _url:String;
		private var _displayName:String;
		private var _bmData:BitmapData;

		public function get bmData():BitmapData
		{
			return _bmData;
		}

		public function set bmData(value:BitmapData):void
		{
			_bmData = value;
		}

		public function get displayName():String
		{
			return _displayName;
		}

		public function set displayName(value:String):void
		{
			_displayName = value;
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