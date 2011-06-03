package com.horizon.components
{
	import com.horizon.model.vos.SurfaceVO;
	import com.sigmagroup.components.Tiler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gs.TweenLite;
	
	public class SurfacesGallery extends Tiler
	{
		public var currentSurface:int;
		
		public function SurfacesGallery(vos:Vector.<Object>, paginate:Boolean, bitmap:Boolean, imageWidth:int, imageHeight:int, horPadding:int, vertPadding:int, specifiedNumOfColumns:int, specifiedNumOfRows:int=1, totalImages:int=0, displayNames:Boolean=false, scale:Number=1, startingX:int = 0, startingY:int = 0)
		{
			initiateDisplayFunction = loadPage;
			super(vos, paginate, bitmap, imageWidth, imageHeight, horPadding, vertPadding, specifiedNumOfColumns, specifiedNumOfRows, totalImages, displayNames, scale, startingX, startingY);
		}
	}
}
