package alwaysAnimationTool.view {
	import com.greensock.TweenMax;

	import graphics.Drawing;

	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.twoD.actions.Explosion;
	import org.flintparticles.twoD.actions.Friction;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.RandomDrift;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.particles.Particle2DUtils;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;

	/**
	 * @author acolling
	 */
	public class DotsDisplay extends Sprite {
		[Embed(source="centre_blur.png")]
		private var _Glow : Class;
		private var _bg : Shape;
		private var _sketchParams : SketchParams;
		private var _circles : Array;
		private var _holder : Sprite;
		private var _bigHolder : Sprite;
		private var _bitmapFilter : BitmapFilter;
		private var _emitter : Emitter2D;
		private var _renderer : DisplayObjectRenderer;
		private var _explosion : Explosion;
		private var _timer : Timer;
		private var _centerGlowHolder : Sprite;
		private var _centerGlowHolderHolder : Sprite;

		public function DotsDisplay() {
			init();
		}

		private function init() : void {
		//	drawBG();
			_bigHolder = new Sprite();
			_bigHolder.x = 150;
			_bigHolder.y = 125;
			addChild(_bigHolder);
			_holder = new Sprite();
			_holder.x = -150;
			_holder.y = -125;
			_bigHolder.addChild(_holder);
			_centerGlowHolderHolder = new Sprite();
			addChild(_centerGlowHolderHolder);
			_centerGlowHolder = new Sprite();
			_centerGlowHolder.x = -150;
			_centerGlowHolder.y = -115;

			var _glow : Bitmap = new _Glow();

			_centerGlowHolder.addChild(_glow);
			_centerGlowHolderHolder.addChild(_centerGlowHolder);
			_centerGlowHolderHolder.x = 150;
			_centerGlowHolderHolder.y = 125;

			createParticlesRenderer();
			_holder.addChild(Drawing.drawBox(1000, 1000, 0xff0000));
			// ,1, 5, 0x0,1));
			addEventListener(Event.ENTER_FRAME, oef);
		}

		private function createParticlesRenderer() : void {
			_emitter = new Emitter2D();
			_emitter.x = 150;
			
			_emitter.y = 125;
			_emitter.addAction(new Move());

			_renderer = new DisplayObjectRenderer();
			_renderer.x = 360;
			_renderer.y = 350;
			_renderer.addEmitter(_emitter);
			// _renderer.filters = [getBlurFilter()];// getBitmapFilter()];
			addChildAt(_renderer, numChildren-1);
			_emitter.start();
		}

		public function explode() : void {
			//add glow to the emitter
			_sketchParams.dotAlpha = .6;
			valuesSet(_sketchParams);
			_renderer.filters [getFinalGlowFilter() ];
			
			// trace("DotsDisplay.explode()  ");
			var arr : Array = getDots();
			arr = setPositionGlobalToLocal(arr);
			var particles : Vector.<Particle> = Particle2DUtils.createParticles2DFromDisplayObjects(arr);
			_emitter.addParticles(particles, false);
			_bigHolder.visible = false;
			_explosion = new Explosion(_sketchParams.explosionPower, -210, -225, _sketchParams.expansionRate, _sketchParams.depth, _sketchParams.epsilon);

			// _renderer.filters = [getBlurFilter()];// getBitmapFilter()];
			_renderer.alpha = _sketchParams.dotAlpha;
			_timer = new Timer(5);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTComplete);
			_timer.start();
			_emitter.addAction(new RandomDrift(30, 30));
			_emitter.addAction(_explosion);
		}

		private function getFinalGlowFilter() : BitmapFilter {
			
			var color : Number = 0xffffff;
			var alpha : Number = .7
			var blurX : Number = 6;
			var blurY : Number = 6;
			var strength : Number = 20;
			var inner : Boolean = false;
			var knockout : Boolean = false;
			var quality : Number = BitmapFilterQuality.HIGH;

			return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}

		private function onTComplete(event : TimerEvent) : void {
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTComplete);
			_emitter.addAction(new Friction(_sketchParams.friction));
		}

		private function setPositionGlobalToLocal(arr : Array) : Array {
			var retA : Array = [];
			for (var i : int = 0; i < arr.length; i++) {
				var dot : DisplayObject = arr[i] as DisplayObject;
				var holder : DisplayObject = dot.parent;
				var dotPos : Point = new Point(dot.x, dot.y)
				var newPos : Point = holder.localToGlobal(dotPos);
				dot.x = newPos.x - 500;
				dot.y = newPos.y - 400;
				retA.push(dot);
			}
			return retA;
		}

		private function getDots() : Array {
			var dotsAll : Array = [];
			for (var i : int = 0; i < _sketchParams.totalCirles; i++) {
				var circle : Circle = _circles[i] as Circle;
				var dots : Array = circle.getDots();

				dotsAll = dotsAll.concat(dots);
			}
			return dotsAll;
		}

		private function oef(event : Event) : void {
			if (!_sketchParams) return;
			_bigHolder.rotation += _sketchParams.rotateSpeed;
		}

		private function drawBG() : void {
			_bg = Drawing.drawBox(300, 250, 0x8bddff);
			addChild(_bg);
		}

		public function valuesSet(sketchParams : SketchParams) : void {
			_sketchParams = sketchParams;

			setFilter();
			generateCircles();
			setCenterGlow();

			_bigHolder.visible = true;
		}

		private function setCenterGlow() : void {
			_centerGlowHolder.alpha = _sketchParams.middleGlowAlpha;
			_centerGlowHolderHolder.scaleX = _centerGlowHolderHolder.scaleY = _sketchParams.middleGlowScale;
		}

		public function removeAllFilters() : void {
			_holder.filters = [];
			_centerGlowHolder.filters = [];
		}

		private function setFilter() : void {
			if (filters.length > 0) {
				filters = [];
			}
			switch(_sketchParams.filterType.label) {
				case "blur":
					//	// trace("adding blur filter");
					var bitmapFilter : BlurFilter = new BlurFilter(_sketchParams.filterSize, _sketchParams.filterSize, 2);
					filters.push(bitmapFilter);
					break;
				case "glow":
					//	// trace("adding glow filter");
					var glowFilter : GlowFilter = getBitmapFilter();
					_holder.filters = [glowFilter];
					_centerGlowHolder.filters = [glowFilter];
					break;
				default:
			}
		}

		public function getBitmapFilter() : GlowFilter {
			var color : Number = _sketchParams.filterColor;
			var alpha : Number = _sketchParams.filterAlpha;
			var blurX : Number = _sketchParams.filterSize;
			var blurY : Number = _sketchParams.filterSize;
			var strength : Number = _sketchParams.filterStrength;
			var inner : Boolean = false;
			var knockout : Boolean = false;
			var quality : Number = BitmapFilterQuality.HIGH;

			return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}

		public function getBlurFilter() : BlurFilter {
			return new BlurFilter(30, 30, 3);
		}

		public function generateCircles() : void {
			// trace("DotsDisplay.generateCircles()  ");

			while (_holder.numChildren > 0) {
				_holder.removeChildAt(0);
			}

			_circles = new Array();

			for (var i : int = 0; i < _sketchParams.totalCirles; i++) {
				var circle : Circle = createNewCircle(i);
				circle.x = 150;
				circle.y = 125;
				_holder.addChild(circle);
				_circles.push(circle);
			}
		}

		private function createNewCircle(i : int) : Circle {
			// total dots, radius, dot radius
			var retCircle : Circle = new Circle(_sketchParams.dotsPerCircle, _sketchParams.initialCircleRadius + (i * _sketchParams.spaceBetweenCircles), _sketchParams.smallestDotRadius + (i * _sketchParams.dotRadiusIncrement), _sketchParams.dotColor, _sketchParams.showCircles, _sketchParams.dotAlpha);
			return retCircle;
		}

		public function removeParticles() : void {
		}

		public function fadeOutCenterGlow() : void {
			TweenMax.to(_centerGlowHolder, 10, {alpha:0});
			
		}
	}
}
