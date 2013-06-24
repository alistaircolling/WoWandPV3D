package {
	import net.hires.debug.Stats;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import fr.seraf.wow.constraint.WSpringConstraint;
	import fr.seraf.wow.core.WOWEngine;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.primitive.WBoundArea;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.primitive.WSphere;

	import graphics.Drawing;

	import com.greensock.TweenLite;
	import com.unitzeroone.pv3d.examples.HelloWorld;

	import org.papervision3d.core.geom.renderables.Vertex3D;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(width="1000", height="800", frameRate="20", backgroundColor="#000000")]
	public class Main extends Sprite {
		private static const WIDTH : Number = 300;
		private static const COLUMNS : Number = 10;
		private static const ROWS : Number = 20;
		private static const HEIGHT : Number = 600;
		private static const CAR_WIDTH : Number = 350;
		private static const CAR_HEIGHT : Number = 300;
		private static const CAR_INIT_Y : Number = 350;
		private static const CAR_INTRO_DURATION : Number = 1.5;
		private static const CAR_STARTED_X : Number = -175;
		private static const CAR_MOVE_ACROSS_DURATION : Number = 2;
		private static const CAR_FINAL_X : Number = 400;
		private static const CAR_INIT_X : Number = -350;
		[Embed(source="img1.png")]
		private var _Bmp1 : Class;
		private static const NUM_OF_BALLS : Number = 8;
		private var wowConstraints : Array;
		private var wow : WOWEngine;
		private var gravity : Number = 0;
		private var carIsChecking : Boolean;
		// = true;
		// = true;
		private var _helloWorld : HelloWorld;
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

		public function Main() {
			_holder2d = new Sprite();
			_holder2d.x = 400;
			_holder2d.y = 80;
			_car = new Sprite();
			_car.addChild(Drawing.drawBox(CAR_WIDTH, CAR_HEIGHT, 0xcccccc, .5));
			_car.x = CAR_INIT_X;
			_car.y = CAR_INIT_Y;
			_holder2d.addChild(_car);

			// _holder2d.addChild(Drawing.drawBox(WIDTH, HEIGHT, 0xefaf3e, 0, 1, 0xefaf3e, 1));
			initPhysics();
			init3D();
			addChild(_holder2d);
			addEventListener(Event.ENTER_FRAME, loop);
			addControls();
			addChild(new Stats());
		}

		private function addControls() : void {
			_startCar = new Sprite();
			_startCar.y = 150;
			_startCar.x = 0;
			_startCar.addChild(Drawing.drawBox(30, 30, 0xffff00));
			addChild(_startCar);
			_startCar.addEventListener(MouseEvent.CLICK, startCar);
			_beginAnim = new Sprite();
			_beginAnim.y = 150;
			_beginAnim.x = 40;
			_beginAnim.addChild(Drawing.drawBox(30, 30, 0x00ff00));
			addChild(_beginAnim);
			_beginAnim.addEventListener(MouseEvent.CLICK, beginAnim);

			_toggleYaw = new Sprite();
			_toggleYaw.y = 150;
			_toggleYaw.x = 120;
			_toggleYaw.addChild(Drawing.drawBox(30, 30, 0xff8ffa));
			addChild(_toggleYaw);
			_toggleYaw.addEventListener(MouseEvent.CLICK, toggleYaw);
			_toggle3D = new Sprite();
			_toggle3D.y = 190;
			_toggle3D.x = 120;
			_toggle3D.addChild(Drawing.drawBox(30, 30, 0xffb465));
			addChild(_toggle3D);
			_toggle3D.addEventListener(MouseEvent.CLICK, _toggle3DOn);
			_resetCar = new Sprite();
			_resetCar.y = 150;
			_resetCar.x = 80;
			_resetCar.addChild(Drawing.drawBox(30, 30, 0x6fe6ff));
			addChild(_resetCar);
			_resetCar.addEventListener(MouseEvent.CLICK, resetCar);
		}

		private function _toggle3DOn(event : MouseEvent) : void {
			vis3d = !vis3d;
		}

		private function resetCar(event : MouseEvent = null) : void {
			carIsChecking = false;
			_car.x = CAR_INIT_X;
		}

		private function toggleYaw(event : MouseEvent) : void {
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

			wow.collisionResponseMode = wow.STANDARD;
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
					if (_y == 0 || _y == ROWS - 1) {
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
			_helloWorld = new HelloWorld(WIDTH, HEIGHT, COLUMNS, ROWS);
			addChild(_helloWorld);
		}

		private function loop(event : Event) : void {
			wow.step();
			syncRenderingToPhysics();
			// if we are to move the curtain
			if (carIsChecking) {
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
			}else{
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
					part.px += (movementX * .5);

					// part.addForce(new WVector())
				}
			}
		}

		public function initCar() : void {
		}

		// loop through particles in wow and set vertivces omn plane to match
		private function syncRenderingToPhysics() : void {
			var part : WParticle;
			var vert : Vertex3D;
			for (var i : int = 0; i < wowVertices.length; i++) {
				part = wowVertices[i] as WParticle;
				vert = _helloWorld.plane.geometry.vertices[i] as Vertex3D;
				vert.x = part.px;
				vert.y = part.py;
				vert.z = part.pz;
			}
		}
	}
}
