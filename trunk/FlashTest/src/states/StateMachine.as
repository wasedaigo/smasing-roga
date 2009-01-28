package states 
{
	import flash.display.BitmapData;
	import states.play.PlayState;
	
	/**
	 * ...
	 * @author ...
	 */
	public class StateMachine 
	{
		private var currentState:BaseState;
		public function StateMachine(initStateID:String) 
		{
			this.setState(initStateID);
		}
		
		public function setState(stateID:String):void 
		{
			switch(stateID) {
				case("play"):
				this.currentState = new PlayState();
				break;
			}
		}
		
		public function update():void 
		{
			if (this.currentState == null) { return; }
			this.currentState.update();
		}
		
		public function render(screen:BitmapData):void 
		{
			if (this.currentState == null) { return; }
			this.currentState.render(screen);
		}
		
	}
	
}