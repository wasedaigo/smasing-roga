package states.play 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import materials.Graphics;
	import states.BaseState;
	import utils.Sprite;

	/**
	 * ...
	 * @author ...
	 */
	public class PlayState extends BaseState
	{
		private var player:states.play.Player;
		public function PlayState() 
		{
			this.player = new states.play.Player();
			var map:Map = new Map(20, 20);
		}
		
		public override function update():void
		{
			this.player.update();
		}
		
		public override function render(screen:BitmapData):void
		{
			this.player.render(screen);
		}
		
	}
	
}