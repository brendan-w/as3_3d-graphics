package turtleCode
{
	//Class that represents and controls an Object in 3D space by maintaining an array of Polygons.
	public class PolyObject {

		public var polygons:Array;
		
		public function PolyObject()
		{
			polygons = new Array;
		}
		
		//Moves the PolyObject according to the offset distances given
		public function moveObject(offset:Point3D):void
		{
			for(var i:int = 0; i < polygons.length; i++)
			{
				polygons[i].movePoly(offset);
			}
		}
		
		//Rotates the PolyObject about the center (if no center, median center is calculated)
		public function rotateObject(offset:Point3D, center:Point3D = null):void
		{
			if(hasPolygons())
			{
				if(center == null)
				{
					center = getCenter();
				}
				for (var i:int = 0; i < polygons.length; i++)
				{
					polygons[i].rotatePoly(offset, center);
				}
			}
		}
		
		//Extrudes a polygon when only one exists in the array
		//If no edge material is given, the original polygon's material is used
		public function extrudePoly(depth:Number, material:Material = null):void
		{
			if(hasPolygons() && (polygons.length == 1))
			{
				if(material == null)
				{
					material = polygons[0].material;
				}
				var offset:Point3D = new Point3D(0,0, depth);
				//create the opposite face
				addPoly(polygons[0].duplicate());
				polygons[1].movePoly(offset);
				polygons[1].flipNormal();
				//create edge polygons
				var edge:Polygon;
				var nextP:int = 0;
				for (var i:int = 0; i < polygons[0].points.length; i++)
				{
					nextP = i + 1;
					if (nextP == polygons[0].points.length) //loop around at end
					{
						nextP = 0;
					}
					edge = new Polygon(material);
					edge.addPoint(polygons[0].points[i].duplicate());
					edge.addPoint(polygons[0].points[nextP].duplicate());
					edge.addPoint(polygons[0].points[nextP].duplicate());
					edge.addPoint(polygons[0].points[i].duplicate());
					edge.points[2].movePoint(offset);
					edge.points[3].movePoint(offset);
					addPoly(edge);
				}
			}
		}
		
		//Calculates the median center of the PolyObject using Polygon.getCenter
		public function getCenter():Point3D
		{
			var center:Point3D = null;
			if (hasPolygons())
			{
				center = new Point3D();
				//loop through each polygon and add each center to the total
				for (var i:int = 0; i < polygons.length; i++)
				{
					center.movePoint(polygons[i].getCenter());
				}
				//divide the total by the number of polygons added
				center = new Point3D(center.x / polygons.length, center.y / polygons.length, center.z / polygons.length);
			}
			return center;
		}
		
		//Creates a new instance of this PolyObject
		public function duplicate():PolyObject
		{
			var newObject:PolyObject = new PolyObject();
			for (var i:int = 0; i < polygons.length; i++)
			{
				newObject.addPoly(polygons[i].duplicate());
			}
			return newObject;
		}
		
		//Returns a boolean value representing if any Polygons are in the array of this PolyObject
		public function hasPolygons():Boolean
		{
			return ((polygons != null) && (polygons.length > 0));
		}
		
		//Append a new polygon to the PolyObject (polygons creating the PolyObject are rendered in the order they were recieved)
		public function addPoly(newPoly:Polygon):void
		{
			polygons[polygons.length] = newPoly;
		}
	}
}