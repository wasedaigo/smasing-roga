package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import states.StateMachine;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import utils.Input;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Main extends Sprite 
	{
		public static function getRGBValue(r:uint,g:uint,b:uint,a:uint = 255):uint
		{
			return (a <<24)|(r<<16)|(g<<8)|(b);
		}
		
		private var gameScreen:BitmapData;
		private var stateMachine:StateMachine;
		private var fps:Number;
		
		public function Main():void 
		{
			if (stage) {
				init();
			}else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
			
			// Add the game screen to the program
			this.gameScreen = new BitmapData(480, 320)
			Input.init(this);
			this.addChild(new Bitmap(this.gameScreen));
			
			// State Machine
			this.stateMachine = new StateMachine("play");
			this.addEventListener(Event.ENTER_FRAME, onTick);
			
		}
		
		private var time:Number;
		public function onTick(event:Event):void {
			Input.update();
			this.stage.focus = this;
			this.stateMachine.update();
			this.gameScreen.fillRect(
				new Rectangle(0, 0, this.gameScreen.width, this.gameScreen.height),
				getRGBValue(127, 127, 127)
			);
			this.stateMachine.render(this.gameScreen);
			// get FPS
			if(this.time > 0){
				this.fps = 1000 / (getTimer() - this.time + 1);
			}
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
	}
	
}