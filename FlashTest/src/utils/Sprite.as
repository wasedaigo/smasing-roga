package utils 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Sprite 
	{
		
		public var position:Point;
		public var srcRect:Rectangle;
		
		private var srcBitmapData:BitmapData;
		public var scaleX:Number;
		public var scaleY:Number;
		private var center:Point;
		public function Sprite(position:Point, srcRect:Rectangle, srcBitmapData:BitmapData, scaleX:int, scaleY:int) 
		{
			this.srcBitmapData = srcBitmapData;
			this.srcRect = srcRect;
			this.position = position;
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.center = new Point(srcBitmapData.width / 2, srcBitmapData.height / 2);
		}
		
		private function getPos():Matrix
		{
			var pos:Matrix = new Matrix();
			
            // Set Center position
			pos.translate( -this.center.x, -this.center.y );
			
			// Scale
			if(this.scaleX != 1.0 || this.scaleY != 1.0){
				pos.scale(this.scaleX, this.scaleY);
			}
			
			// Move
            var x:Number = this.position.x + this.center.x;
            var y:Number = this.position.y + this.center.y;
				
			var tx:Number;
			var ty:Number;
			if (this.scaleX == 1){
				tx = this.srcRect.x;
			}else {
				tx = this.srcBitmapData.width - this.srcRect.x - this.srcRect.width;
			}
			
			if (this.scaleY == 1){
				ty = this.srcRect.y;
			}else {
				ty = this.srcBitmapData.height - this.srcRect.y - this.srcRect.height;
			}
				
			pos.translate(x - tx, y - ty);
			
			return pos;
		}
		
		public function isExpensive():Boolean
		{
			return (this.scaleX != 1.0) || (this.scaleY |= 1.0);
		}
		
		public function render(screen:BitmapData):void
		{
			if (this.isExpensive()) {
				var pos:Matrix = this.getPos();
				
				var clipRect:Rectangle = new Rectangle(this.position.x, this.position.y, this.srcRect.width, this.srcRect.height);
				screen.draw(this.srcBitmapData, pos, null, null, clipRect);	
			}else {
				screen.copyPixels(this.srcBitmapData, this.srcRect, this.position, null, null, true);	
			}

			
		}
	}
	
}