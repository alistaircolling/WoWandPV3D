package {
	import fr.seraf.wow.constraint.WSpringConstraint;
	import fr.seraf.wow.core.WOWEngine;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.primitive.WParticle;

	import graphics.Drawing;

	import hires.debug.Stats;

	import uk.co.soulwire.gui.SimpleGUI;

	import com.greensock.TweenLite;
	import com.unitzeroone.pv3d.examples.HelloWorld;

	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	[SWF(width="1000", height="800", frameRate="20", backgroundColor="#000000")]
	public class Main extends Sprite {
		private static const WIDTH : Number = 300;
		private static const COLUMNS : Number = 10;
		private static const ROWS : Number = 20;
		private static const HEIGHT : Number = 600;
		private static const CAR_WIDTH : Number = 300;
		private static const CAR_HEIGHT : Number = 200;
		private static const CAR_INIT_Y : Number = 400;
		private static const CAR_INTRO_DURATION : Number = 1.5;
		private static const CAR_STARTED_X : Number = -175;
		private static const CAR_MOVE_ACROSS_DURATION : Number = 5;
		private static const CAR_FINAL_X : Number = 1000;
		private static const CAR_INIT_X : Number = -350;
		[Embed(source="img1.png")]
		private var _Bmp1 : Class;
		[Embed(source="leaf.png")]
		private var _Leaf : Class;
		private static const NUM_OF_BALLS : Number = 8;
		private var wowConstraints : Array;
		private var wow : WOWEngine;
		private var gravity : Number = 0;
		private var carIsChecking : Boolean;
		// = true;
		// = true;
		public var _helloWorld : HelloWorld;
		private var wowVertices : Array;
		private var _holder2d : Sprite;
		private var _car : Sprite;
		private var _startCar : Sprite;
		private var _beginAnim : Sprite;
		private var _toggleYaw : Sprite;
		private var isYaw : Boolean;
		private var _resetCar : Sprite;
		private var lastCarRect : Rectangle;
		private var movementX : Number = 0;
		private var _toggle3D : Sprite;
		private var vis3d : Boolean = true;
		private var _gui : SimpleGUI;
		private var guiHolder : Sprite;
		private var _toggleMaterial : Boolean;
		private var debug : Boolean = true;
		private var curtainBmpd : BitmapData;

		public function Main() {
			_holder2d = new Sprite();
			_holder2d.x = 400;
			_holder2d.y = 80;

			_car = new Sprite();
			_car.addChild(Drawing.drawBox(CAR_WIDTH, CAR_HEIGHT, 0x00ff00, .5));
			_car.x = CAR_INIT_X;
			_car.y = CAR_INIT_Y;
			var leaf : Bitmap = new _Leaf();
			leaf.x = -150;
			_car.addChild(leaf);
			_holder2d.addChild(_car);

			setBitmap(new _Bmp1().bitmapData);
		}

		private function setBitmap(bmpd : BitmapData) : void {
			curtainBmpd = flipBitmapData(bmpd, "y");
			initPhysics();
			init3D();
			addChild(_holder2d);
			addEventListener(Event.ENTER_FRAME, loop);
			addGUI();
			var stat : Stats = new Stats();
			stat.x = 900;
			addChild(stat);
			syncRenderingToPhysics();
		}

		public function flipBitmapData(original : BitmapData, axis : String = "x") : BitmapData {
			var flipped : BitmapData = new BitmapData(original.width, original.height, true, 0);
			var matrix : Matrix
			if (axis == "x") {
				matrix = new Matrix(-1, 0, 0, 1, original.width, 0);
			} else {
				matrix = new Matrix(1, 0, 0, -1, 0, original.height);
			}
			flipped.draw(original, matrix, null, null, null, true);
			return flipped;
		}

		private function addGUI() : void {
			_gui = new SimpleGUI(this, "GUI", "C");

			_gui.addSlider("_helloWorld.light.x", -1000, 1000, {label:"LIGHT X", width:370, y:20});
			_gui.addSlider("_helloWorld.light.y", -1000, 1000, {label:"LIGHT Y", width:370, y:40});
			_gui.addSlider("_helloWorld.light.z", -1000, 1000, {label:"LIGHT Z", width:370, y:60});
			_gui.addButton("START CAR", {callback:startCar, x:0, y:100});
			_gui.addButton("BEGIN ANIM", {callback:beginAnim, x:0, y:120});
			_gui.addButton("RESET CAR", {callback:resetCar, x:0, y:140});
			_gui.addButton("RESET PHYSICS", {callback:resetPhysics, x:0, y:160});
			_gui.addButton("TOGGLE 2D", {callback:toggleYaw, x:0, y:180});
			_gui.addButton("TOGGLE 3D", {callback:_toggle3DOn, x:0, y:200});
			_gui.addToggle("toggleMaterial", {x:0, y:230});
			_gui.addButton("PRINT VERTICES", {callback:printVertices, x:0, y:200});
			_gui.show();

			_helloWorld.light.x = 22.9;
			_helloWorld.light.y = -152.7;
			_helloWorld.light.z = 1000;
		}

		private function printVertices() : void {
			trace("=========== PRINT VERTICES ===========");
			for (var i : int = 0; i < wowVertices.length; i++) {
				var part : WParticle = wowVertices[i] as WParticle;
				var vert3d : Vertex3D = _helloWorld.plane.geometry.vertices[i] as Vertex3D;
				trace(i + " x:" + Math.round(part.px) + "," + Math.round(vert3d.x + 150) + " y:" + Math.round(part.py) + "," + Math.round(vert3d.y + 300) + " z:" + Math.round(part.pz) + "," + Math.round(vert3d.z));
			}
			trace("=========== END ===========");
		}

		private function resetPhysics() : void {
			var xStep : Number = WIDTH / (COLUMNS - 1);
			var yStep : Number = HEIGHT / (ROWS - 1);
			var particle : WParticle;
			var lastPart : WParticle;
			var counter : uint = 0;
			for (var _x : int = 0; _x < COLUMNS; _x++) {
				for (var _y : int = 0; _y < ROWS; _y++) {
					particle = wowVertices[counter];
					particle.px = _x * xStep;
					particle.py = _y * yStep;
					particle.pz = 0;
					if (_y == 0 || _y == ROWS - 1) {
						particle.fixed = true;
					}
					counter++;
				}
			}
			syncRenderingToPhysics();
		}

		private function _toggle3DOn(event : MouseEvent = null) : void {
			vis3d = !vis3d;
		}

		private function resetCar(event : MouseEvent = null) : void {
			carIsChecking = false;
			_car.x = CAR_INIT_X;
		}

		private function toggleYaw(event : MouseEvent = null) : void {
			isYaw = !isYaw;
			if (!isYaw) {
				// planeHolder.rotationY = 0;
				// _activeHolder.rotationY = 0;
			}
		}

		private function beginAnim(event : MouseEvent = null) : void {
			carIsChecking = true;
			// gravity = -.6;
			TweenLite.to(_car, CAR_MOVE_ACROSS_DURATION, {x:CAR_FINAL_X, onComplete:animationComplete});
		}

		private function animationComplete() : void {
			carIsChecking = false;
		}

		private function startCar(event : MouseEvent = null) : void {
			TweenLite.to(_car, CAR_INTRO_DURATION, {x:CAR_STARTED_X});
		}

		private function initPhysics() : void {
			// keep the objects in an array, so we can access them later on

			wowVertices = new Array();
			wowConstraints = new Array();

			// init wow basics
			wow = new WOWEngine();
			wow.damping = .4;

			wow.collisionResponseMode = wow.SELECTIVE;
			// add some gravity
			wow.addMasslessForce(new WVector(0, gravity, 0));

			var constraint : WSpringConstraint;
			var xStep : Number = WIDTH / (COLUMNS - 1);
			var yStep : Number = HEIGHT / (ROWS - 1);
			var particle : WParticle;
			var lastPart : WParticle;

			for (var _x : int = 0; _x < COLUMNS; _x++) {
				for (var _y : int = 0; _y < ROWS; _y++) {
					particle = new WParticle(_x * xStep, _y * yStep, 0, false);
					// , 1, .3, 0);
					// if (_y == 0){// || _y == ROWS - 1) {
					if (_y == ROWS - 1) {
						particle.fixed = true;
						// could be fixed x
					}
					// particle.addForce(new WVector(Math.random(),Math.random(),0));
					wow.addParticle(particle);
					wowVertices.push(particle);
				}
			}
			var currIndex : uint;
			for ( _x = 0; _x < COLUMNS; _x++) {
				for ( _y = 0; _y < ROWS; _y++) {
					if (_x < COLUMNS - 1) {
						currIndex = (_x * ROWS) + _y;
						lastPart = wowVertices[currIndex];
						particle = wowVertices[currIndex + ROWS];
						constraint = new WSpringConstraint(lastPart, particle, 1);

						wowConstraints.push(constraint);
						wow.addConstraint(constraint);
					}
					if (_y < ROWS - 1) {
						currIndex = (_x * ROWS) + _y;
						lastPart = wowVertices[currIndex];
						particle = wowVertices[currIndex + 1];
						constraint = new WSpringConstraint(lastPart, particle, 1);
						wowConstraints.push(constraint);
						wow.addConstraint(constraint);
					}
				}
			}
		}

		private function init3D() : void {
			_helloWorld = new HelloWorld(WIDTH, HEIGHT, COLUMNS, ROWS, curtainBmpd);
			addChild(_helloWorld);
		}

		private function loop(event : Event) : void {
			wow.step();

			// if we are to move the curtain
			if (carIsChecking) {
				syncRenderingToPhysics();
				// calculate the movement of the car
				var r : Rectangle = _car.getRect(_holder2d);
				if (lastCarRect) {
					movementX = r.x - lastCarRect.x;
				}
				lastCarRect = r;
				// check which points are in the car
				getPointsInsideCar();
			}
			if (vis3d) {
				_helloWorld.visible = true;
				_helloWorld.singleRender();
			} else {
				_helloWorld.visible = false;
			}
			if (isYaw) {
				draw2D();
			} else {
				_holder2d.graphics.clear();
			}
		}

		private function draw2D() : void {
			_holder2d.graphics.clear();
			var part : WParticle;
			var top : uint = wowVertices.length;
			for (var i : int = 0; i < top; i++) {
				part = wowVertices[i] as WParticle;
				_holder2d.graphics.beginFill(0xffff00);
				_holder2d.graphics.drawCircle(part.px, part.py, 3);
			}
			var constr : WSpringConstraint;
			top = wowConstraints.length;
			for ( i = 0; i < top; i++) {
				constr = wowConstraints[i]  as WSpringConstraint;
				_holder2d.graphics.beginFill(0xffff00);
				_holder2d.graphics.lineStyle(1, 0x00ff00);
				_holder2d.graphics.moveTo(constr.pxp1, constr.pyp1);
				_holder2d.graphics.lineTo(constr.pxp2, constr.pyp2);
			}
		}

		// get the particles inside the car and move them by the amout the car has moved
		private function getPointsInsideCar() : void {
			// vertices
			var part : WParticle;
			var top : uint = wowVertices.length;
			for (var i : int = 0; i < top; i++) {
				part = wowVertices[i] as WParticle;
				// part.fixedY = true;
				if (lastCarRect.containsPoint(new Point(part.px, part.py))) {
					part.px += (movementX * .8);
				}
			}
		}

		// loop through particles in wow and set vertivces omn plane to match
		private function syncRenderingToPhysics() : void {
			var p1 : WParticle;
			var p2 : WParticle;
			var p3 : WParticle;
			var p4 : WParticle;
			var top : uint = wowVertices.length;
			var v1 : Vertex3D;
			var v2 : Vertex3D;
			var v3 : Vertex3D;
			var v4 : Vertex3D;
			var f1 : Triangle3D;
			var f2 : Triangle3D;
			for (var i : int = 0; i < top ; i++) {
				p1 = wowVertices[i] as WParticle;
				v1 = _helloWorld.plane.geometry.vertices[i] as Vertex3D;
				v1.x = p1.px;
				v1.y = p1.py;
				v1.z = p1.pz;
			}
			/*	for (var i : int = 0; i < top-ROWS; i+=4) {
			p1 = wowVertices[i];
			p2 = wowVertices[i+1];
			p3 = wowVertices[i+ROWS];
			p4 = wowVertices[i+ROWS+1];
			v1 = new Vertex3D(p1.px, p1.py, p1.pz);
			v2 = new Vertex3D(p2.px, p2.py, p2.pz);
			v3 = new Vertex3D(p3.px, p3.py, p3.pz);
			v4 = new Vertex3D(p4.px, p4.py, p4.pz);
			_helloWorld.mesh.geometry.vertices.push(v1, v2, v3,v4);
			f1 = new Triangle3D(_helloWorld.mesh, [v1, v2, v3],_helloWorld.getShadedBitmapMaterial(_helloWorld.planeMaterial, "gouraud") );
			f2 = new Triangle3D(_helloWorld.mesh, [v1, v3, v4],_helloWorld.getShadedBitmapMaterial(_helloWorld.planeMaterial, "gouraud") );
			_helloWorld.mesh.geometry.faces.push(f1);
			_helloWorld.mesh.geometry.faces.push(f2);
			}
			_helloWorld.mesh.geometry.ready = true;*/
		}

		public function get toggleMaterial() : Boolean {
			return _toggleMaterial;
		}

		public function set toggleMaterial(toggleMaterial : Boolean) : void {
			_toggleMaterial = toggleMaterial;
			_helloWorld.toggleMaterial();
		}
	}
}
