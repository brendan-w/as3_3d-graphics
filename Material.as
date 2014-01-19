package turtleCode
{
	import flash.geom.Point;

	//Class for holding and computing material data
	public class Material
	{
	
		public var fillColor:Number;		//Hex fillcolor
		public var sheenColor:Number;		//Hex color of sheen when directly reflecting light
		public var fillOpacity:Number;		//0 to 1 opacity for the fill
		public var strokeWidth:Number;		//stroke width in pixels
		public var strokeColor:Number;		//Hex stroke color
		public var strokeOpacity:Number;	//0 to 1 opacity for the stroke
		public var diffuseAngle:Number;		//margin in which the sheen angle is linearly applied
		public var singleSided:Boolean;		//determines if the other (non-normal) side of a polygon is effected by the sheen reflectance
		
		public function Material(newFillColor:Number = 0x0000FF,
								 newSheenColor:Number = 0x000000,
								 newFillOpacity:Number = 0.5,
								 newStrokeWidth:Number = 1,
								 newStrokeColor:Number = 0x000000,
								 newStrokeOpacity:Number = 1,
								 newDiffuseAngle:Number = 10,
								 newSingleSided:Boolean = true)
		{
			fillColor = newFillColor;
			sheenColor = newSheenColor;
			fillOpacity = newFillOpacity;
			strokeWidth = newStrokeWidth;
			strokeColor = newStrokeColor;
			strokeOpacity = newStrokeOpacity;
			diffuseAngle = newDiffuseAngle;
			singleSided = newSingleSided;
		}
		
		//Method for computing what the fill shade of a given polygon will be
		public function getShade(polygon:Polygon, camera:CameraOb):Number
		{
			var angle:Number = getAngle(polygon, camera);
			//If the polygon reflects on booth sides of the normal, consider the opposite side
			if((!singleSided) && (angle > 90))
			{
				angle = Math.abs(angle - 180);
			}
			//calculate the percent of full reflectance achieved (1 = perfectly reflective, 0.1 = 10% reflective)
			var percent:Number = angle / diffuseAngle;
			percent = 1 - percent;
			
			//reflect the proper amount of the sheenColor
			if(percent > 0)
			{
				var color:Object = ColorControl.hexToRGB(fillColor);
				var sheen:Object = ColorControl.hexToRGB(sheenColor);
				
				color.red = color.red + ((sheen.red - color.red) * percent)
				color.green = color.green + ((sheen.green - color.green) * percent)
				color.blue = color.blue + ((sheen.blue - color.blue) * percent)
				
				return ColorControl.RGBtoHex(color.red, color.green, color.blue);
			}
			else //no sheen necessary, give the ambient color
			{
				return fillColor;
			}
		}
		
		//method that computes the angle between the normal vector of a polygon and the camera vector (using the dot product)
		public function getAngle(polygon:Polygon, camera:CameraOb):Number
		{
			var reflect:Point3D = polygon.getNormal();
			var trueV:Point3D = getVector(polygon.getCenter(), camera.position);
			
			return 180*(Math.acos((reflect.x*trueV.x) + (reflect.y*trueV.y) + (reflect.z*trueV.z)) / Math.PI);
		}
		
		//method for generating the vector from one point to another
		public function getVector(p1:Point3D, p2:Point3D):Point3D
		{
			var v1:Point3D = new Point3D(p2.x - p1.x,
										 p2.y - p1.y,
										 p2.z - p1.z);
			v1.normalizeV();
			return v1;
		}
	}
}