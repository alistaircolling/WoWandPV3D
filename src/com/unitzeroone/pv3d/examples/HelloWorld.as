package com.unitzeroone.pv3d.examples {
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapColorMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.shaders.CellShader;
	import org.papervision3d.materials.shaders.FlatShader;
	import org.papervision3d.materials.shaders.GouraudShader;
	import org.papervision3d.materials.shaders.PhongShader;
	import org.papervision3d.materials.shaders.ShadedMaterial;
	import org.papervision3d.materials.shaders.Shader;
	import org.papervision3d.materials.special.VectorShapeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	/**
	 * @author Ralph Hauwert
	 */
	public class HelloWorld extends BasicView {
		private static const CAR_WIDTH : Number = 350;
		private static const CAR_HEIGHT : Number = 150;
		private static const CAR_INIT_Y : Number = -125;
		private static const CAR_INTRO_DURATION : Number = 1.5;
		private static const CAR_STARTED_X : Number = -175;
		private static const CAR_MOVE_ACROSS_DURATION : Number = 4;
		private static const CAR_FINAL_X : Number = 400;
		private static const CAR_INIT_X : Number = -370;
		protected var curtainBMPD : BitmapData;
		public var planeMaterial : BitmapMaterial;
		public var light : PointLight3D;
		public var mesh : TriangleMesh3D;
		private var vectMat : VectorShapeMaterial;
		public var plane : Plane;
		private var perlin : BitmapData;
		private var move : Number = 0;
		private var bmpColor : BitmapColorMaterial;
		private var sphere : Sphere;
		private var wireMaterial : WireframeMaterial;
		public var planeHolder : DisplayObject3D;
		private var _carWire : WireframeMaterial;
		private var car : Cube;
		private var materiallist : MaterialsList;
		private var _yellowWire : WireframeMaterial;
		private var _yellowList : MaterialsList;
		private var _activeHolder : DisplayObject3D;
		private var isYaw : Boolean;
		private var _resetCar : Sprite;
		private var bannerWidth : Number;
		private var bannerHeight : Number;
		private var columns : Number;
		private var rows : uint;
		private var isBitmap : Boolean;
		private var shaders : Array = ["flat", "cell", "gouraud", "phong"];
		private var _shadeIndex : uint = 0;

		/**
		 * HelloWorld
		 * 
		 * HelloWorld extends BasicView, which is an utility class for Papervision3D, which automatically sets up
		 * Scene, Camera, Renderer and Viewport for you.
		 * 
		 * This allows for easy Papervision3D initialization.
		 * 
		 * This HelloWorld example utilizes BasicView to set up the the basics, and then extends upon it and setup a basic primitive and material.
		 */
		public function HelloWorld(w : Number, h : Number, cols : Number, rowss : Number, bmpd : BitmapData) {
			/**
			 * Call the BasicView constructor.
			 * Width and Height are set to 1, since scaleToStage is set to true, these will be overriden.
			 * We will not use interactivity and keep the default cameraType.
			 */
			super(1, 1, true, false);
			curtainBMPD = bmpd;
			bannerWidth = w;
			bannerHeight = h;
			columns = cols;
			rows = rowss;
			// Color the background of this basicview / helloworld instance black.
			opaqueBackground = 0;

			// Create the materials and primitives.
			initScene();

			// Call the native startRendering function, to render every frame.
			// startRendering();
		}

		/**
		 * initScene will create the needed primitives, and materials.
		 */
		protected function initScene() : void {
			// create bitmap texture

			planeMaterial = new BitmapMaterial(curtainBMPD, false);
			wireMaterial = new WireframeMaterial(0xfffffff, 100, 1);
			wireMaterial.doubleSided = true;
			// add light
			light = new PointLight3D(true);
			light.x = 0;
			light.z = 1000;

			plane = new Plane(getShadedBitmapMaterial(planeMaterial, "gouraud"), bannerWidth, bannerHeight, columns - 1, rows - 1);

			planeHolder = new DisplayObject3D();
			plane.y = -300;
			plane.x = -150;
			scene.addChild(DisplayObject3D(planeHolder));
			planeHolder.addChild(plane);
			// planeHolder.y = 300;
			planeHolder.rotationX = 180;
			// planeHolder.rotationY = 180;
			// planeHolder.rotationZ = 180;

			_activeHolder = new DisplayObject3D();
			scene.addChild(_activeHolder);
			_carWire = new WireframeMaterial(0xff00ff, 100, 1);
			_carWire.doubleSided = true;
			materiallist = new MaterialsList();
			materiallist.addMaterial(_carWire, "front");
			materiallist.addMaterial(_carWire, "back");
			materiallist.addMaterial(_carWire, "left");
			materiallist.addMaterial(_carWire, "right");
			materiallist.addMaterial(_carWire, "top");
			materiallist.addMaterial(_carWire, "bottom");

			_yellowWire = new WireframeMaterial(0xffff, 100, 1);
			_yellowWire.doubleSided = true;
			_yellowList = new MaterialsList();
			_yellowList.addMaterial(_carWire, "front");
			_yellowList.addMaterial(_carWire, "back");
			_yellowList.addMaterial(_carWire, "left");
			_yellowList.addMaterial(_carWire, "right");
			_yellowList.addMaterial(_carWire, "top");
			_yellowList.addMaterial(_carWire, "bottom");

			/*	car = new Cube(materiallist, CAR_WIDTH, 20, CAR_HEIGHT);
			car.x = 0 - CAR_WIDTH;
			car.y = CAR_INIT_Y
			planeHolder.addChild(car);*/
			scene.addChild(planeHolder);
			camera.z = -347;

			// addChild(new Stats());
		}

		public function getShadedBitmapMaterial(bitmapMaterial : BitmapMaterial, shaderType : String) : ShadedMaterial {
			var shader : Shader;

			if (shaderType == "flat") {
				// create new flat shader
				shader = new FlatShader(light, 0xFFFFFF, 0x333333);
			} else if (shaderType == "cell") {
				// create new cell shader with 5 colour levels
				shader = new CellShader(light, 0xFFFFFF, 0x333333, 5);
			} else if (shaderType == "gouraud") {
				// create new gouraud shader
				shader = new GouraudShader(light, 0xFFFFFF, 0x333333);
			} else if (shaderType == "phong") {
				// create new phong shader
				shader = new PhongShader(light, 0xFFFFFF, 0x333333, 50);
			}

			// create new shaded material by combining the bitmap material with shader
			var shadedMaterial : ShadedMaterial = new ShadedMaterial(bitmapMaterial, shader);
			shadedMaterial.interactive = true;
			shadedMaterial.doubleSided = true;

			return shadedMaterial;
		}

		public function updateVertices(arr : Array) : void {
		}

		/**
		 * onRenderTick();
		 * 
		 * onRenderTick can be overriden so you can execute code on a per render basis, using basicview.
		 * in this case we use it to
		 */
		override protected function onRenderTick(event : Event = null) : void {
			if (isYaw) {
				planeHolder.yaw(.7);
				_activeHolder.yaw(.7);
			}
			/*
			var vs : Array = plane.geometry.vertices;
			var vc : int = vs.length;

			for (var i : int = 0; i < vc; i++) {
			var px : int = i % 300;
			var py : int = i / 600;
			var v : Vertex3D = vs[i] as Vertex3D;
			var vzpos : Number = perlin.getPixel(px, py) & 0xff;
			v.z = (128 - vzpos) * (mouseX / stage.stageWidth);
			}

			// Call the super.onRenderTick function, which renders the scene to the viewport using the renderer and camera classes.
			super.onRenderTick(event);
			trace(mouseX + ":" + mouseY);
			light.x = mouseX;
			light.y = mouseY;*/

			super.onRenderTick(event);
		}

	
		public function setBitmap(bmpd : BitmapData) : void {
			curtainBMPD = bmpd;
		}

		public function getPointsInsideCar() : Array {
			/*		for (var o:Object in _activeHolder.children) {
			_activeHolder.removeChild(_activeHolder.children[o]);
			}*/
			var retA : Array = [];

			// iterate through each of the vertices that make up the grid and check if they are inside the car
			var tot : int = plane.geometry.vertices.length;
			for (var i : int = 0; i < tot; i++) {
				var vertice : Vertex3D = plane.geometry.vertices[i] as Vertex3D;
				if (car.hitTestPoint(vertice.x, vertice.y, vertice.z)) {
					/*var plan : Plane = new Plane(_yellowWire, 5, 5, 5);
					plan.x = vertice.x;
					plan.y = vertice.y;
					plan.z = vertice.z;
					_activeHolder.addChild(plan);*/
					retA.push(vertice);
				}
			}
			return retA;
		}

		public function render() : void {
			onRenderTick();
		}

		public function toggleMaterial() : void {
			isBitmap = !isBitmap;
			if (isBitmap) {
				var s : String = shaders[_shadeIndex];
				plane.material = getShadedBitmapMaterial(planeMaterial, s);
				if (_shadeIndex < shaders.length - 1) {
					_shadeIndex++;
				} else {
					_shadeIndex = 0;
				}
			} else {
				plane.material = wireMaterial;
			}
		}
	}
}