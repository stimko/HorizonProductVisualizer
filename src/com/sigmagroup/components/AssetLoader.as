/**
 * @author:
 * 		Joe Schorn -		jschorn@sigmagroup.com
 * 		
 * 
 */
package com.sigmagroup.components
{
	
	import flash.events.EventDispatcher;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.Font;

	public class AssetLoader extends EventDispatcher
	{
/////////// CONSTANTS ///////////////////
		public static const ASSETS_PROGRESS:String = "assetsProgress";
		public static const ASSETS_LOADED:String = "assetsLoaded";		
		
		private var _swfPath:String;
		private var _ldr:Loader;
		private var _context:LoaderContext;
		private var _fontsDomain:ApplicationDomain;
		private var _percentLoaded:Number = 0;
		
		public function AssetLoader(swfPath:String)
			{
			_swfPath = swfPath;
			}
		
		public function load():void
			{
			_ldr = new Loader ();
			_context = new LoaderContext();
			_context.applicationDomain = ApplicationDomain.currentDomain;
			_fontsDomain = _ldr.contentLoaderInfo.applicationDomain;
			_ldr.load(new URLRequest(_swfPath), _context);
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			}
			
		public function getProgress():Number
			{
			return _percentLoaded
			}
	
		private function onError(e:IOErrorEvent):void
			{
			trace("AssetLoader :: Error -- failed to load -- " + e)
			} 

		protected function onProgress(e:ProgressEvent):void
			{
			var percLoaded:Number = e.bytesLoaded/e.bytesTotal;
			_percentLoaded = Math.round(percLoaded * 100);
			dispatchEvent(new Event(AssetLoader.ASSETS_PROGRESS));
			}
		
		protected function onComplete(e:Event):void
			{
			//trace("AssetLoader :: loading complete")
			dispatchEvent(new Event(AssetLoader.ASSETS_LOADED));
			}
		
		public function getMovieClip(linkageID:String):MovieClip
			{
			//trace("AssetLoader :: getting MovieClip " + linkageID + " from " + _ldr.contentLoaderInfo);
			var clip:MovieClip;
			try	{
				var MovieAsset:Class = _ldr.contentLoaderInfo.applicationDomain.getDefinition(linkageID) as Class;
				 clip = new MovieAsset();
				}
			catch (e:Error)
				{
				trace("Asset Loader :: unable to locate MovieClip: " + linkageID);		
				}
			return clip
			}

		public function getBitmap(linkageID:String):Bitmap
			{
			//trace("AssetLoader :: getting Bitmap " + linkageID + " from " + _ldr.contentLoaderInfo);
			var image:Bitmap;
			try	{
				var ImageAsset:Class = _ldr.contentLoaderInfo.applicationDomain.getDefinition(linkageID) as Class;
				var imageData:BitmapData = new ImageAsset(0, 0) as BitmapData; 
				image = new Bitmap(imageData, "auto", true);
				}
			catch (e:Error)
				{
				trace("Asset Loader :: unable to locate Bitmap: " + linkageID);		
				}
			return image
			}
			
 	 	public function getFont(linkageID:String):Font 
 	 		{
 	 	 	var fontClass:Class = getFontClass(linkageID);
 	 	 	Font.registerFont(fontClass);
 	 	 	return new fontClass as  Font;
 	 		}

 	 	private function getFontClass(linkageID:String):Class 
 	 		{
 	 		try {
	 	 		_fontsDomain = _ldr.contentLoaderInfo.applicationDomain;
 	 	 		}
 	 	 	catch (e:Error)
				{
				trace("Asset Loader :: unable to locate Font: " + linkageID);		
				}
	 	 	return _fontsDomain.getDefinition(linkageID)  as  Class;
 	 	 	}
		

	}//end class
}//end package