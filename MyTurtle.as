package turtleCode
{
	import flash.display.*;
	import flash.geom.Point;
	
	public class MyTurtle extends Turtle
	{
		private var camera:CameraOb; //Pointer to the camera
		
		public function MyTurtle(cam:CameraOb)
		{
			//     x  y  time  color  width
			super (0, 0, 10, 0x000000, 1);
			camera = cam;
		}
		
		//Method to clear the screen before the next frame is rendered
		public function clearScreen():void
		{
			super.pShape.graphics.clear();
		}
		
		//Method to draw 3D objects to the screen
		public function drawObject(object:PolyObject):void
		{
			//loop through polygons within object
			for(var i:int = 0; i < object.polygons.length; i++)
			{
				drawPoly(object.polygons[i]);
				//drawPolyNormals(object.polygons[i]);
			}
		}
		
		
		//Method to draw the surface normal of a polygon to the screen
		public function drawPolyNormals(polygon:Polygon):void
		{
			if(polygon.points.length >= 1)
			{
				//go to the start position of the polygon
				penUp();
				moveAbs(project(polygon.getCenter()).x, project(polygon.getCenter()).y);
				penDown();
				//get the normal point and make it 0-10
				var v1:Point3D = polygon.getNormal();
				v1 = new Point3D(v1.x*10,
								 v1.y*10,
								 v1.z*10);	
				//set the beg stroke to full black
				setStroke(0x000000, 1, 1);
				var startP:Point3D = polygon.getCenter().duplicate();
				startP.movePoint(v1);
				//draw the normal
				line(polygon.getCenter(), startP);
				penUp();
			}
		}
		
		//Method to draw 3D polygons to the screen
		public function drawPoly(polygon:Polygon):void
		{
			if(polygon.points.length >= 1)
			{
				//go to the start position of the polygon
				penUp();
				moveAbs(project(polygon.points[0]).x, project(polygon.points[0]).y);
				penDown();
				//load material properties
				beginFill(polygon.material.getShade(polygon, camera), polygon.material.fillOpacity);
				setStroke(polygon.material.strokeColor, polygon.material.strokeWidth, polygon.material.strokeOpacity);
				//generate each line between each point
				for(var i:int = 0; i < (polygon.points.length - 1); i++)
				{
					line(polygon.points[i], polygon.points[i + 1]);
				}
				//complete the polygon if neccessary
				if(polygon.points.length >= 3)
				{
					line(polygon.points[polygon.points.length - 1], polygon.points[0]);
				}
				endFill();
				penUp();
			}
		}

		//method for drawing 3D lines to the screen. Method also contains interpolation
		private function line(startP3:Point3D, endP3:Point3D):void
		{
			//get the 2D screen coordinates of the start and end points
			var startP2:Point  = project(startP3);
			var endP2:Point  = project(endP3);
			//calculate the number of pixels between the two endpoints
			var dist:Number = Math.sqrt(Math.pow(endP2.x - startP3.x, 2) + Math.pow(endP2.y - startP3.y, 2));
			var num:int = int(dist/camera.res) + 1;
			moveAbs(startP2.x, startP2.y);
			//if intersticial points are needed, add them
			if(num > 1)
			{
				var offP3:Point3D = new Point3D;
				var curP3:Point3D = startP3.duplicate();
				//calculate the offset from one interpolated point to the next
				offP3.x = (endP3.x - startP3.x) / num
				offP3.y = (endP3.y - startP3.y) / num
				offP3.z = (endP3.z - startP3.z) / num
				curP3.movePoint(offP3);
				for(var i:int = 0; i < (num - 1); i++)
				{
					startP2 = project(curP3);
					moveAbs(startP2.x, startP2.y);
					curP3.movePoint(offP3);
				}
			}
			moveAbs(endP2.x, endP2.y);
		}
		
		//3D to 2D conversion through projection of angles
		public function project(point:Point3D):Point
		{
			var stageWidth:Number = stage.stageWidth;
			var stageHeight:Number = stage.stageHeight;
			//compute horizontal angle
			var h_Dist:Number = Math.sqrt(Math.pow((point.y - camera.position.y),2) + Math.pow((point.z - camera.position.z),2));
			var h_Angle:Number = Math.atan((point.x - camera.position.x)/h_Dist);
			//compute vertical angle
			var v_Dist:Number = Math.sqrt(Math.pow((point.x - camera.position.x),2) + Math.pow((point.z - camera.position.z),2));
			var v_Angle:Number = Math.atan((point.y - camera.position.y)/v_Dist);
			v_Angle*=-1; //positive Y is down on computers
			//Project the angles
			var radians:Number = (camera.lens/360) * Math.PI //360 becuase angles are centered
			var screen_Dist:Number = (stageWidth) / (Math.tan(radians));
			
			var x_Coordinate:Number = (screen_Dist * Math.tan(h_Angle)) + (stageWidth / 2);
			var y_Coordinate:Number = (screen_Dist * Math.tan(v_Angle)) + (stageHeight / 2);
			
			//Alternate method for projecting the angles
			/*
			h_Dist = screen_Dist / Math.cos(v_Angle);
			var x_Coordinate:Number = (h_Dist * Math.tan(h_Angle)) + (stageWidth / 2);
			v_Dist = screen_Dist / Math.cos(h_Angle);
			var y_Coordinate:Number = (v_Dist * Math.tan(v_Angle)) + (stageHeight / 2);
			*/
			
			return new Point(x_Coordinate, y_Coordinate);
		}
	}
}