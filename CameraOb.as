package turtleCode
{
	import flash.geom.Point;
	
	//Class to represent the camera
	public class CameraOb
	{
		public var position:Point3D; //3D Position
		public var lens:Number;      //Max angle that the camera can view
		public var res:Number;       //Number of pixels to travel before interpolating

		public function CameraOb(newPosition:Point3D,
								 newLens:Number = 90,
								 newRes:Number = 20)
		{
			position = newPosition;
			lens = newLens;
			res = newRes;
		}
		public function moveCamera(offset:Point3D):void
		{
			position.movePoint(offset);
		}
	}
}