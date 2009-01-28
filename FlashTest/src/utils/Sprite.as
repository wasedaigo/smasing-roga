package utils 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Sprite 
	{
		private var srcBitmapData:BitmapData;
		public var pos:Point;
		public var srcRect:Rectangle;
		public function Sprite(pos:Point, srcRect:Rectangle, srcBitmapData:BitmapData) 
		{
			this.srcBitmapData = srcBitmapData;
			this.srcRect = srcRect;
			this.pos = pos;
		}
		
		public function render(screen:BitmapData):void
		{
			screen.copyPixels(this.srcBitmapData, this.srcRect, this.pos, null, null, true);
		}
	}
	
}