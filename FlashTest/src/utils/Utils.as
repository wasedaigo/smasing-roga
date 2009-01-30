package utils 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class Utils 
	{
		/*
		 *	Generate two dimentional Array
		 */
		public static function getTwoDimentionalArray(xCount:uint, yCount:uint, srcData:Array = null):Array
		{
			var i:int, j:int;
			var srcArray:Array = new Array(xCount);
			for (i = 0; i < xCount; i++)
			{
				srcArray[i] = new Array(yCount);
			}
			
			// Fill data passed
			if (srcData != null)
			{
				try {
					var idx:int = 0;
					for (i = 0; i < xCount; i++)
					{
						for (j = 0; j < yCount; j++)
						{
							srcArray[i][j] = srcData[idx];
							idx++;
						}	
					}
				}
				catch (e:Error)
				{
					trace("Illegal access to srcData[]");
				}
			}

			return srcArray;
		}
		
	}
	
}