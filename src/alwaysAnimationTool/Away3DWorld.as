package alwaysAnimationTool {
	import mx.core.mx_internal;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.math.Number3D;
	import away3d.lights.PointLight3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.WhiteShadingBitmapMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.RegularPolygon;
	import away3d.primitives.Skybox;
	import away3d.primitives.Sphere;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;

	/**
	 * @author acolling
	 */
	public class Away3DWorld extends Sprite {
			private var view:View3D;
		
		private var starField:Skybox;
		private var earth:Sphere;
		private var sun:Mesh;
		private var moon:Sphere;
		private var sunLight:PointLight3D;
		
		
		private var earthRotation:Number = Math.PI;
		private var moonDistance:Number = 400;
		private var moonEllipse:Number = 5;
		
		private var CAM_Y_BASE:Number;
		private var CAM_X_BASE:Number;
		private var mouseMultiplier:Number = -50;
		private var mouseEasing:Number = .2;
		private var simulationRate:Number = 1;
		
		private var cameraLocations:Array;
		private var cameraLocIndex:int = -1;
		
		private var paused:Boolean = false;
		private var simRateAcc:Number = 0;

		[Embed(source = "img1.png")]
		private var Earth:Class;
		
		[Embed(source = "img2.png")]
		private var Moon:Class;
		
		[Embed(source = "img2.png")]
		private var Stars : Class;
		private var mesh : Mesh;
		private var cube : Cube;
		private var plane : Plane;
		private var bannerWidth : Number;
		private var bannerHeight : Number;
		private var columns : uint;
		private var rows : uint;
		private var curtainBitmap : BitmapData;
		private var _material : BitmapMaterial;
		
		
		
		
		public function Away3DWorld(wid:Number, hei:Number, col:uint, row:uint, bmpd:BitmapData) {
			
			bannerWidth = wid;
			bannerHeight = hei;
			columns = col;
			rows = row;
			curtainBitmap = bmpd;
			
			
			(stage)?init():addEventListener(Event.ADDED_TO_STAGE, oas);
			
		}

		private function oas(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, oas);
			init();
		}


		
		

		private function init() : void {
			view = new View3D();
			view.x = stage.stageWidth / 2;
			view.y = stage.stageHeight / 2;
			addChild(view);
			
			// Light
			sunLight = new PointLight3D( { x:1200, y:0, z: -600, brightness:5, ambient:30, diffuse:500, specular:180 } );
			view.scene.addChild(sunLight);
			
			// Sun
			var sunMat:ColorMaterial = new ColorMaterial(0xffffff);
			sun = new RegularPolygon( { material:sunMat, radius:100, sides:32, x:2400, y:0, z: -1200 } );
			sun.rotationZ = 90;
			view.scene.addChild(sun);
			sun.ownCanvas = true;
			sun.filters = [new GlowFilter(0xffffbe, 1, 12, 12, 3, 3, false, false), new GlowFilter(0xffffbe, 1, 12, 12, 3, 3, true, false)];
			
		//	plane =  new Plane({width:bannerWidth, height:bannerHeight,segmentsW:columns, segmentsH:rows, material:sunMat, yUp:false });
			//plane.ownCanvas = true;
			//view.scene.addChild(plane);
			
			_material = new BitmapMaterial(curtainBitmap, true);
			
			plane = new Plane(_material);
			plane.yUp = false;
			view.scene.addChild(plane);
			
			
			
			
			
			// Earth
			var earthBmp:Bitmap = new Earth() as Bitmap;
			var earthMat:WhiteShadingBitmapMaterial = new WhiteShadingBitmapMaterial(earthBmp.bitmapData);
			earthMat.ambient_brightness = 2;
			earthMat.diffuse_brightness = 1.7;
			earthMat.specular_brightness = 0;
			earth = new Sphere( { material:earthMat, radius:150, segmentsW:32, segmentsH:18, y:0, x:0, z:0 } );
			earth.rotationZ = -8;
			view.scene.addChild(earth);
			
			// Moon
			var moonBmp:Bitmap = new Moon() as Bitmap;
			var moonMat:WhiteShadingBitmapMaterial = new WhiteShadingBitmapMaterial(moonBmp.bitmapData);
			moonMat.ambient_brightness = 0;
			moonMat.diffuse_brightness = 1.2;
			moonMat.specular_brightness = 0;
			moon = new Sphere( { material:moonMat, radius:16, segmentsW:24, segmentsH:12, y:0, x:moonDistance, z:moonDistance } );
			view.scene.addChild(moon);
			
			
			
			var starBmp:Bitmap = new Stars() as Bitmap;
			var starFieldMat:BitmapMaterial = new BitmapMaterial(starBmp.bitmapData);
			starField = new Skybox(starFieldMat, starFieldMat, starFieldMat, starFieldMat, starFieldMat, starFieldMat);
		//	view.scene.addChild(starField);
			
			sunLight.lookAt(new Number3D(0, 0, 0));
			view.camera.lookAt(new Number3D(0, 0, 0));
			
			
			
		}

		public function singleRender() : void {
			view.render();
		}
	}
}
