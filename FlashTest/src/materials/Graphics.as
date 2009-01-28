package materials 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Graphics 
	{
		private static var collection:Dictionary = new Dictionary();
		public static function getBitmapData(cls:Class):BitmapData
		{
			if(collection[cls] == null){
				collection[cls] = new cls().bitmapData;
			}
			return collection[cls];
		}
		
		
		[Embed(source='../../res/images/play/sample_battle.png')]
        public static var BattlerSample:Class;
		
		[Embed(source='../../res/images/play/shirou_battle.png')]
        public static var ShirouBattle:Class;
	}
	
}