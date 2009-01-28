package utils 
{
	import flash.utils.Dictionary;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.ui.KeyLocation;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author ...
	 */
	public class Input 
	{
		private static var
		mouseX:uint = 0,
		mouseY:uint = 0;

		private static var
		mouseMoved:Boolean = false,
		mouseClicked:Boolean = false,
		mousePressed:Boolean = false;

		private static var Pressed:Array  = new Array();
		private static var PreviousPressed:Array  = new Array();
		private static var RepeatingState:Array  = new Array();
		private static var TimeState:Array  = new Array();
	  
		// Get and set multiple key detection time frame
		public function get AllowableError():int{return 5;}
			public function set AllowableError(value:int):void{}
			
		/// Get and set key repeating delay
		public function get Delay():int{return 5;}
			public function set Delay(value:int):void{}      

		// Get and set key repeating interval
		public function get interval():int{return 5; }
			public function set interval(value:int):void{}


		public function get isEnabled():Boolean{return true; }
			public function set isEnabled(value:Boolean):void{}
			
		public static function isMouseClicked():Boolean{return mouseClicked; }
		
		public static function isMousePressed():Boolean{return mousePressed; }
		
		public static function isPressed(keyCode:uint):Boolean
		{
			return Pressed.indexOf(keyCode) >= 0;
		}

		// Whether the key is pressed newly
		public static function isPressedNewly(keyCode:uint):Boolean
		{
			return (PreviousPressed.indexOf(keyCode) < 0) && (isPressed(keyCode));
		}

		// Whether the key was pressed within previous loop
		public static function isPressedPrevious(keyCode:uint):Boolean
		{
			return PreviousPressed.indexOf(keyCode) >= 0;
		}
		
		public static function init(base:flash.display.Sprite):void
		{
			 base.addEventListener(KeyboardEvent.KEY_UP,keyUp);
			 base.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			 base.addEventListener(MouseEvent.CLICK, mouseClick);
			 base.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			 base.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			 base.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}

		public static function update():void{
		  // Store keys pressed within last loop
		  PreviousPressed.length = 0;
		  for each(var KeyCode:uint in Pressed)
		  {
				PreviousPressed.push(KeyCode);
			}
			
			//Reset mouse click state
			mouseClicked = false;
		}

		//縲When the key released
		private static function keyUp(event:KeyboardEvent):void{
		  Pressed.splice(Pressed.indexOf(event.keyCode), 1);
		}
		
		// When the key is pushed, store it to the table
		private static function keyDown(event:KeyboardEvent):void {
			if(Pressed.indexOf(event.keyCode)<0){
			Pressed.push( event.keyCode );
			}
		}
		
		// Store mouse location, when the mouse moved
		private static function mouseMove(event:MouseEvent):void
		{
			mouseX = event.localX;
			mouseY = event.localY;
		}
	 
		// Store mouse location, when the mouse down
		private static function mouseDown(event:MouseEvent):void
		{
			mouseX = event.localX;
			mouseY = event.localY;
			mousePressed = true;
		}
		
		// When the mouse released
		private static function mouseUp(event:MouseEvent):void
		{
			mousePressed = false;
		}   
		// When the mouse clicked
		private static function mouseClick(event:MouseEvent):void
		{
			mouseClicked = true;
		}
	}
	
}
