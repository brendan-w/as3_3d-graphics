/*
Written & Designed by: Brendan Whitfield
Date: 9-30-2012
Notes:
	The tools and techniques used in this project were learned in previous programming
	(and math) classes from high school.
	
	Class functions were referenced online from the Adobe ActionScript 3.0 Reference Manual
	http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/Math.html
	http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html
	http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/TimerEvent.html
	
	Algorithm for computing surface normals was discovered at:
	http://www.lighthouse3d.com/opengl/terrain/index.php3?normals
	
	Minor edits and bypasses were made to the Turtle class to facilitate use with this system

The Big-Picture:
	All 3D to 2D conversions take place in MyTurtle
	MyTurtle draws PolyObjects (using a CameraOb for render settings)
	PolyObjects are made of Polygons
	Polygons are made of Point3Ds
	Polygons also contain pointers to Materials
	MyTurtle references Materials for coloring and shading
	
	All PolyObjects for the scene are stored in the "model" array.
	The Model is generated at the start of the program and is rotated by the Timer.
	Since the main material is glass, object occlusion is only processed on the bullet.
	Because of this, the bullet object is split in two, and is always stored in the last two elements of the model array.
	
*/

package turtleCode
{
	import flash.display.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	//Class to create and render a bullet/glass impact
	public class Main extends MovieClip
	{
		//System Variables=======================================
		private var camera:CameraOb;
		private var model:Array;
		private var myT:MyTurtle;
		private var pTimer:Timer;
		
		//System Settings========================================
		private var lens:Number = 55;
		private var res_Limit:Number = 75;
		private var camera_Position:Point3D = new Point3D(0,0,0);
		private var frame_Rate:Number = 125;
		private var rot_Increment:Point3D = new Point3D(0,3,0);
		
		//Modelling Settings====================================
		//Material Shader Data-----------------------------------
		private var glass_Surface:Material = new Material(0x88E9E0, 0xD1E8E6, 0.15, 1, 0x88E9E0, 0, 10, false);
		private var glass_Edge:Material = new Material(0x29996D, 0x1C6648, 0.35, 1, 0x29996D, 0.3, 0, false);
		private var bullet:Material = new Material(0x806221, 0xDDB45C, 1, 1, 0x000000, 0, 65, true);
		private var smoke:Material = new Material(0x000000, 0xFFFFFF, 0.1, 1, 0x000000, 0, 360, false);
		//GLASS FRACTURE Variables-------------------------------
		private var glass_Center:Point3D = new Point3D(0,0,1400);
		private var glass_Thickness:Number = 7;
		private var glass_Slices:int = 18;
		//Ring 1 (Inner Ring)
		private var ring1_Radius:Number = 50;
		private var ring1_Variance:Number = 50;
		private var ring1_Angle:Number = 55;
		private var ring1_Angle_Variance:Number = 45;
		private var ring1_Offset:Point3D = new Point3D(0,0,60);
		private var ring1_Offset_Variance:Number = 50;
		//Ring 2 (Outer Ring)
		private var ring2_Radius:Number = 150;
		private var ring2_Variance:Number = 50;
		private var ring2_Angle:Number = 20;
		private var ring2_Angle_Variance:Number = 15;
		private var ring2_Offset:Point3D = new Point3D(0,0,0);
		private var ring2_Offset_Variance:Number = 40;
		//Outer Glass (Solid)
		private var outer_Slices:int = 3;
		private var outer_Size:Number = 400/2;
		//BULLET Variables---------------------------------------
		private var bullet_Position:Point3D = new Point3D(0,0,glass_Center.z + 200);
		private var bullet_Vertices:Number = 30;
		private var bullet_End_Radius:Number = 10;
		private var bullet_Radius:Number = 15;
		private var bullet_TailLength:Number = 25;
		private var bullet_BodyLength:Number = 35;
		private var bullet_Nose:Point3D = new Point3D(0,0,bullet_Position.z + 150);
		
		
		public function Main()
		{
			trace("Started...");
			camera = new CameraOb(camera_Position,lens,res_Limit);  //Create the camera
			myT = new MyTurtle(camera);						        //Create the turtle
			addChild(myT);									        //Add turtle to system
			myT.hideTurtle();
			
			model = new Array;					 //Create model Array
			buildModel();					     //Construct Model Array
			turnModel(new Point3D(0,180,0));	 //spin the model to face forward
			
			//start the timer
			pTimer = new Timer(frame_Rate);
			pTimer.addEventListener(TimerEvent.TIMER, cycle);
			pTimer.start();
		}		
		
		//Method called by the timer event
		public function cycle(e:TimerEvent):void
		{
			if(model.length >= 2) //If there's objects in the model
			{
				
				myT.clearScreen(); //clear the screen
				//the two sides of the bullet are always the last elements in the array
				var bullet1:PolyObject = model[model.length - 1]; //1st Half
				var bullet2:PolyObject = model[model.length - 2]; //2nd Half
				var drawAfter:Boolean = true;
				
				//rotate all the objects in the model
				turnModel(rot_Increment);
				
				//rotate the box, which is always behind everything
				myT.drawObject(model[0]);
				//test if the bullet is behind the glass
				if(bullet1.getCenter().z >= glass_Center.z)
				{
					drawBullet(bullet1, bullet2);
					drawAfter = false;
				}
				//render the everything but the bullet
				for(var j:int = 1; j < (model.length - 2); j++)
				{
					myT.drawObject(model[j]); //Draw each object
				}
				//if the bullet was in front of the glass, render it last
				if(drawAfter)
				{
					drawBullet(bullet1, bullet2);
				}
			}
		}
		
		//method that draws the bullet by determining which half is facing the camera
		public function drawBullet(bullet1:PolyObject, bullet2:PolyObject):void
		{
			if(bullet1.getCenter().x >= glass_Center.x)
			{
				//side 1 is faceing the camera
				myT.drawObject(bullet2);
				myT.drawObject(bullet1);
			}
			else
			{
				//side 2 is faceing the camera
				myT.drawObject(bullet1);
				myT.drawObject(bullet2);
			}
		}
		
		//method to rotate all the objects in the model
		public function turnModel(rot:Point3D):void
		{
			//loop through every object and rotate
			for(var i:int = 0; i < model.length; i++)
			{
				model[i].rotateObject(rot, glass_Center);
			}
		}
		
		//method to generate the entire model based on the model settings above
		private function buildModel():void
		{
			var nextP:int = 0;
			var poly:Polygon;
			var object:PolyObject;
			
			//GLASS FRACTURE Process=============================================
			//Define/Create corner points of each ring--------------
			var ring1:Array = new Array;
			var ring2:Array = new Array;
			//Create arrays of radial points
			for(var a:int = 0; a < 360; a+=(360/glass_Slices))
			{
				ring1[ring1.length] = radial(a, ring1_Radius, ring1_Variance, glass_Center.z);
				ring2[ring2.length] = radial(a, ring2_Radius, ring2_Variance, glass_Center.z);
			}
			//Create Polygons out of the corner points--------------
			for(var c:int = 0; c < ring1.length; c++)
			{
				nextP = c + 1;
				if(nextP == ring1.length) //loop around at end
				{
					nextP = 0;
				}
				//First ring-----------------------
				poly = new Polygon(glass_Surface);
				poly.addPoint(ring1[c]);
				poly.addPoint(ring1[nextP]);
				poly.addPoint(glass_Center);
				object = new PolyObject();
				object.addPoly(poly.duplicate());
				//Apply modifiers
				object.extrudePoly(glass_Thickness, glass_Edge);
				object.rotateObject(roll(glass_Slices, c, ring1_Angle, ring1_Angle_Variance), midPoint(ring1[c], ring1[nextP]));
				object.moveObject(new Point3D(ring1_Offset.x, ring1_Offset.y, ring1_Offset.z + Math.random() * ring1_Offset_Variance));
				//Load object into the model
				model[model.length] = object;
				
				//Second Ring----------------------
				poly = new Polygon(glass_Surface);
				poly.addPoint(ring2[c]);
				poly.addPoint(ring2[nextP]);
				poly.addPoint(ring1[nextP]);
				poly.addPoint(ring1[c]);
				object = new PolyObject();
				object.addPoly(poly.duplicate());
				//Apply modifiers
				object.extrudePoly(glass_Thickness, glass_Edge);
				object.rotateObject(roll(glass_Slices, c, ring2_Angle, ring2_Angle_Variance), midPoint(ring2[c], ring2[nextP]));
				object.moveObject(new Point3D(ring2_Offset.x, ring2_Offset.y, ring2_Offset.z + Math.random() * ring2_Offset_Variance));
				//Load object into the model
				model[model.length] = object;
			}

			//GLASS SOLID Process=======================================
			poly = new Polygon(glass_Surface);
			poly.addPoint(new Point3D(outer_Size, -outer_Size, glass_Center.z));
			poly.addPoint(new Point3D(outer_Size, 0, glass_Center.z));
			//Add the points for the outer edge of the glass fracture to the solid glass polygon
			for(var b:int = 0; b < ring1.length; b++)
			{
				poly.addPoint(ring2[b]);
			}
			poly.addPoint(ring2[0]);
			poly.addPoint(new Point3D(outer_Size, 0, glass_Center.z));
			poly.addPoint(new Point3D(outer_Size, outer_Size, glass_Center.z));
			poly.addPoint(new Point3D(-outer_Size, outer_Size, glass_Center.z));
			poly.addPoint(new Point3D(-outer_Size, -outer_Size, glass_Center.z));
			object = new PolyObject();
			object.addPoly(poly.duplicate());
			//Apply modifiers
			object.extrudePoly(glass_Thickness, glass_Edge);
			//Load object into the model
			model[model.length] = object;

			//BULLET Process=============================================
			var bullet_End_Ring:Array = new Array;
			var bullet_Ring:Array = new Array;
			var bullet_Upper_Ring:Array = new Array;
			//Create arrays of key radial points around the bullet
			for(var d:int = 0; d < 360; d+=(360/bullet_Vertices))
			{
				bullet_End_Ring[bullet_End_Ring.length] = radial(d + 90, bullet_End_Radius, 0, bullet_Position.z);
				bullet_Ring[bullet_Ring.length] = radial(d + 90, bullet_Radius, 0, bullet_Position.z + bullet_TailLength);
				bullet_Upper_Ring[bullet_Upper_Ring.length] = radial(d + 90, bullet_Radius, 0, bullet_Position.z + bullet_TailLength + bullet_BodyLength);
			}
			//Bullet--------------------------------
			object = new PolyObject();
			for(var e:int = 0; e < bullet_Ring.length; e++)
			{
				nextP = e + 1;
				if(nextP == bullet_Ring.length) //loop around at end
				{
					nextP = 0;
				}
				//Point Panels----------------------
				poly = new Polygon(bullet);
				poly.addPoint(bullet_Upper_Ring[e]);
				poly.addPoint(bullet_Upper_Ring[nextP]);
				poly.addPoint(bullet_Nose);
				object.addPoly(poly.duplicate());
				//Body Panels----------------------
				poly = new Polygon(bullet);
				poly.addPoint(bullet_Ring[e]);
				poly.addPoint(bullet_Ring[nextP]);
				poly.addPoint(bullet_Upper_Ring[nextP]);
				poly.addPoint(bullet_Upper_Ring[e]);
				object.addPoly(poly.duplicate());
				//Tail Panels----------------------
				poly = new Polygon(bullet);
				poly.addPoint(bullet_End_Ring[e]);
				poly.addPoint(bullet_End_Ring[nextP]);
				poly.addPoint(bullet_Ring[nextP]);
				poly.addPoint(bullet_Ring[e]);
				object.addPoly(poly.duplicate());
				//Filled Ending Circle-------------
				poly = new Polygon(bullet);
				poly.addPoint(bullet_End_Ring[e]);
				poly.addPoint(bullet_End_Ring[nextP]);
				poly.addPoint(bullet_Position);
				poly.flipNormal();
				object.addPoly(poly.duplicate());
				
				//detect if the halfway mark has been reached.
				if(e == int(bullet_Ring.length / 2))
				{
					model[model.length] = object; //load the current half into the model
					object = new PolyObject(); //begin the next half
				}
			}
			//Load object into the model
			model[model.length] = object;
		}
		
		//Method that returns the 3D point at a radial position dictated by the angle and radius
		public function radial(angle:Number, radius:Number, variance:Number, z:Number):Point3D
		{
			angle = (angle / 180) * Math.PI;
			radius = radius + ((Math.random() - 0.5) * variance);
			return new Point3D(Math.cos(angle) * radius, Math.sin(angle) * radius, z);
		}
		
		//Method that rolls objects in a toroidal fashion around the center point
		public function roll(total_Slices:int, slice_Number:int, angle:Number, variance:Number):Point3D
		{
			angle = angle + ((Math.random() - 0.5) * variance);
			var singleAngle = (360/total_Slices);
			var sliceAngle:Number = (singleAngle * slice_Number) + (singleAngle / 2);
			sliceAngle = (sliceAngle / 180) * Math.PI;
			return new Point3D(Math.sin(sliceAngle) * angle, Math.cos(sliceAngle) * angle, 0);
		}
		
		//method that returns the midpoint of a line dictated by two points
		public function midPoint(A:Point3D, B:Point3D):Point3D
		{
			return new Point3D(A.x +((B.x - A.x) / 2),
							   A.y +((B.y - A.y) / 2),
							   A.z +((B.z - A.z) / 2));
		}
	}
}