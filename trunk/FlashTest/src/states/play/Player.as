package states.play 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import materials.Graphics;
	import utils.Input;
	import utils.Key;
	import utils.Sprite;

	/**
	 * ...
	 * @author ...
	 */
	public class Player 
	{
		public static const GROUND_LINE:int = 100;
		
		public static var
			RUN:int = 0,
			JUMPING:int = 1,
			JUMP:int = 2,
			LANDING:int = 3,
			ATTAKING_AIR:int = 4,
			DASH:int = 5;
			
		private var sprite:Sprite,
		frameX:int, frameY:int,
		frameTimer:int,
		speed:int,
		gravity:int,
		jumpBoost:Number, jumpPower:Number,
		vx:Number, vy:Number,
		state:int;
		
		public function Player() 
		{
			this.state = 0;
			this.frameTimer = 0;
			this.frameX = 0;
			this.frameY = 0;
			this.gravity = 1;
			this.jumpPower = 7;
			this.jumpBoost = 0;
			this.speed = 2;
			this.sprite = new Sprite(
				new Point(100, GROUND_LINE), 
				new Rectangle(0, 0, 32, 32), 
				Graphics.getBitmapData(Graphics.BattlerSample), 
				1, 
				1
			);
		}
		
		public function update():void {
			switch(this.state){
				
			case(RUN):
				var dash:Boolean = false;
				var speedMultiplier:Number = 1;
				var startFrame:int = 1;
				var endFrame:int = 7;
				var frameTime:Number = 3; 
				if (Input.isPressed(Key.SHIFT)) {
					if (Input.isPressedNewly(Key.SHIFT)) {
						this.frameX = 0;
						this.frameTimer = 0;
					}
					speedMultiplier = 3;
					startFrame = 12;
					endFrame = 18;
					frameTime = 2; 
					dash = true;
				}
				
				if (!Input.isPressed(Key.LEFT) && !Input.isPressed(Key.RIGHT)) {
					this.frameTimer = 0;
					this.frameX = 0;
				}else {
					
					if (Input.isPressed(Key.LEFT)) {
						this.sprite.scaleX = 1;
						this.sprite.position.x -= this.speed * speedMultiplier;
						this.frameTimer++;
						if (frameTimer > frameTime) {
							this.frameTimer = 0;
							this.frameX++;
							if (this.frameX < startFrame) {
								this.frameX = startFrame;
							}
						}
					}
					
					if (Input.isPressed(Key.RIGHT)) {
						this.sprite.scaleX = -1;
						this.sprite.position.x += this.speed * speedMultiplier;
						this.frameTimer++;
						if (this.frameTimer > frameTime) {
							this.frameTimer = 0;
							this.frameX++;
							if (this.frameX < startFrame) {
								this.frameX = startFrame;
							}
						}
					}
				}
				
				if (this.frameX > endFrame) {
					this.frameX = startFrame;
				}
				
				if (Input.isPressed(Key.UP)) {
					this.frameTimer = 0;
					this.frameX = 9;
					this.state = JUMPING;
				}
				break;
			case(JUMPING):
					this.frameTimer++;
					if (this.frameTimer >= 2) {
						this.frameX = 10;
						this.state = JUMP;
						this.vy = this.jumpPower;
						this.jumpBoost = 1.1;
					}else {
						this.frameX = 9;
					}
			break;
				case(JUMP):
					if (Input.isPressed(Key.LEFT)) {
						this.sprite.scaleX = 1;
						this.sprite.position.x -= this.speed;
					}
					
					if (Input.isPressed(Key.RIGHT)) {
						this.sprite.scaleX = -1;
						this.sprite.position.x += this.speed;
					}
					
					this.frameTimer++;
					if (this.frameTimer >= 2) {
						if(this.vy >= 0){
							this.frameX = 10;
							if (Input.isPressed(Key.UP)) {
								if(this.jumpBoost > 1){
									this.jumpBoost = 1.5;
								}
							}else {
								this.jumpBoost = 1;
							}
						}else {
							this.frameX = 11;	
						}
						this.sprite.position.y -= this.vy;
						this.vy -= this.gravity / this.jumpBoost;
						if (this.sprite.position.y > GROUND_LINE) {
							this.sprite.position.y = GROUND_LINE;
							this.state = LANDING;
							this.frameX = 10;
							this.frameTimer = 0;
						}
					}
				break;
			case(LANDING):
					this.frameTimer++;
					if (this.frameTimer >= 2) {
						this.frameX = 0;
						this.frameTimer = 0;
						this.state = RUN;
					}else {
						this.frameX = 9;
					}
				break;

			}
			

			
			this.sprite.srcRect.x = this.frameX * this.sprite.srcRect.width;
			this.sprite.srcRect.y = this.frameY * this.sprite.srcRect.height;
		}
		
		public function render(screen:BitmapData):void {
			this.sprite.render(screen);
		}
	}
	
}