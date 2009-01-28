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
			ATTAKING_AIR:int = 4;
			
		private var sprite:Sprite,
		frameX:int, frameY:int,
		frameTime:int, frameTimer:int,
		speed:int,
		gravity:int,
		jumpBoost:Number, jumpPower:Number,
		vx:Number, vy:Number,
		state:int;
		
		public function Player() 
		{
			this.state = 0;
			this.frameTimer = 0;
			this.frameTime = 3;
			this.frameX = 0;
			this.frameY = 0;
			this.gravity = 1;
			this.jumpPower = 10;
			this.jumpBoost = 0;
			this.speed = 5;
			this.sprite = new Sprite(new Point(100, GROUND_LINE), new Rectangle(0, 0, 32, 32), Graphics.getBitmapData(Graphics.BattlerSample));
		}
		
		public function update():void {
			switch(this.state){
				case(RUN):
				
				if (!Input.isPressed(Key.LEFT) && !Input.isPressed(Key.RIGHT)) {
					this.frameTimer = 0;
					this.frameX = 0;
				}else {
					
					if (Input.isPressed(Key.LEFT)) {
						this.frameY = 0;
						this.sprite.pos.x -= this.speed;
						this.frameTimer++;
						if (this.frameTimer > this.frameTime) {
							this.frameTimer = 0;
							this.frameX++;
						}
					}
					
					if (Input.isPressed(Key.RIGHT)) {
						this.frameY = 1;
						this.sprite.pos.x += this.speed;
						this.frameTimer++;
						if (this.frameTimer > this.frameTime) {
							this.frameTimer = 0;
							this.frameX++;
						}
					}
				}
				
				if (this.frameX > 7) {
					this.frameX = 1;
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
						this.frameY = 0;
						this.sprite.pos.x -= this.speed;
					}
					
					if (Input.isPressed(Key.RIGHT)) {
						this.frameY = 1;
						this.sprite.pos.x += this.speed;
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
						this.sprite.pos.y -= this.vy;
						this.vy -= this.gravity / this.jumpBoost;
						if (this.sprite.pos.y > GROUND_LINE) {
							this.sprite.pos.y = GROUND_LINE;
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
				case(ATTAKING_AIR):
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