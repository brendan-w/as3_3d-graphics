package turtleCode
{
	import flash.geom.Point;

	//Class that represents a polygon in 3D space by maintaining an array of Point3Ds.
	public class Polygon
	{

		public var points:Array;
		public var material:Material;

		//Constructor, Optional argument to duplicate current polygon
		public function Polygon(newMaterial:Material = null)
		{
			material = newMaterial;
			points = new Array  ;
		}
		public function setMaterial(newMaterial):void
		{
			material = newMaterial;
		}
		
		//Method to additively offset the polygon based on XYZ data of a Point3D
		public function movePoly(offset:Point3D):void
		{
			for (var i:int = 0; i < points.length; i++)
			{
				points[i].movePoint(offset);
			}
		}
		
		//Method to ratate a polygon by offsetting its points.
		//Rotations are applied in XYZ order.
		//If no center is defined, median center is used.
		public function rotatePoly(offset:Point3D, center:Point3D = null):void
		{
			if (hasPoints())
			{
				if (center == null){center = getCenter();}
				//push to center
				movePoly(new Point3D(-center.x, -center.y, -center.z));

				//compute the radian offsets
				var xRot:Number = (offset.x/180) * Math.PI * -1;
				var yRot:Number = (offset.y/180) * Math.PI * -1;
				var zRot:Number = (offset.z/180) * Math.PI * -1;
				
				var temp:Number;

				for (var i = 0; i < points.length; i++)
				{
					if (xRot != 0) //X rotation
					{
							   temp = points[i].y * Math.cos(xRot) - points[i].z * Math.sin(xRot);
						points[i].z = points[i].y * Math.sin(xRot) + points[i].z * Math.cos(xRot);
						points[i].y = temp;
					}
					if (yRot != 0) //Y rotation
					{
						       temp = points[i].x * Math.cos(yRot) - points[i].z * Math.sin(yRot);
						points[i].z = points[i].x * Math.sin(yRot) + points[i].z * Math.cos(yRot);
						points[i].x = temp;
					}
					if (zRot != 0) //Z rotation
					{
						       temp = points[i].x * Math.cos(zRot) - points[i].y * Math.sin(zRot);
						points[i].y = points[i].x * Math.sin(zRot) + points[i].y * Math.cos(zRot);
						points[i].x = temp;
					}
				}
				//pop from center to original location
				movePoly(center);
			}
		}
		
		//Method returning the median center of the polygon
		public function getCenter():Point3D
		{
			var center:Point3D = null;
			if (hasPoints())
			{
				center = new Point3D();
				for (var i:int = 0; i < points.length; i++)
				{
					center.movePoint(points[i]);
				}
				center = new Point3D(center.x / points.length,center.y / points.length,center.z / points.length);
			}
			return center;
		}
		
		//Method that computes the surface normal vector of the polygon, and returns it in a Point3D object
		public function getNormal():Point3D
		{
			var normal:Point3D;
			if(hasPoints() && (points.length >= 3))
			{
				//calculate two vectors from the first 3 points in the array
				var v1:Point3D = new Point3D(points[1].x - points[0].x,
											 points[1].y - points[0].y,
											 points[1].z - points[0].z);
				var v2:Point3D = new Point3D(points[2].x - points[0].x,
											 points[2].y - points[0].y,
											 points[2].z - points[0].z);
				//calculate the vector cross product
				normal = new Point3D((v1.y * v2.z) - (v1.z * v2.y),
									 (v1.z * v2.x) - (v1.x * v2.z),
									 (v1.x * v2.y) - (v1.y * v2.x));
				//normalize the vector
				normal.normalizeV();
			}
			return normal;
		}
		
		//Creates another instance of this polygon
		public function duplicate():Polygon
		{
			var newPoly:Polygon = new Polygon(material);
			for (var i:int = 0; i < points.length; i++)
			{
				newPoly.addPoint(points[i].duplicate());
			}
			return newPoly;
		}
		
		public function flipNormal()
		{
			points.reverse();
		}
		
		//Method that determines whether this polygon contains points to operate on.
		public function hasPoints():Boolean
		{
			return ((points != null) && (points.length > 0));
		}
		
		//Append a new point to the polygon (points creating the polygon are rendered in the order they were recieved)
		public function addPoint(newPoint:Point3D):void
		{
			points[points.length] = newPoint;
		}
	}
}