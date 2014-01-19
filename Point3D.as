package turtleCode
{
	//Class that represents and controls a point, vector, and rotation offset in 3D space
	public class Point3D {
		//3D Position
		public var x:Number;
		public var y:Number;
		public var z:Number;

		public function Point3D(newX:Number = 0,
								newY:Number = 0,
								newZ:Number = 0) {
			x = newX;
			y = newY;
			z = newZ;
		}
		
		//Method to additively offset the point based on XYZ data of another Point3D
		public function movePoint(offset:Point3D):void
		{
			x+=offset.x;
			y+=offset.y;
			z+=offset.z;
		}
		
		//Creates another instance of this point
		public function duplicate():Point3D
		{
			return new Point3D(x,y,z);
		}
		
		//method for normalizing vector data in the point
		public function normalizeV():void
		{
			var factor:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2) + Math.pow(z, 2));
			x/=factor;
			y/=factor;
			z/=factor;
		}
		
		//for debug
		public function toString():String
		{
			return("X:" + x + " Y:" + y + " Z:" + z);
		}
	}
}