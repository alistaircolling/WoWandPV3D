package particles.SampleApp {
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.counters.ZeroCounter;

	import flash.filters.GlowFilter;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	import graphics.Drawing;

	import net.hires.debug.*;

	import org.flintparticles.common.events.ParticleEvent;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;

	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	[SWF(width="1000", height="800", frameRate="30", backgroundColor="#e9e9e9")]
	public class FlintZone extends Sprite {
		[Embed(source="branding.png", mimeType="image/png")]
		private var Branding : Class;
		[Embed(source="bg.png", mimeType="image/png")]
		private var BG : Class;
		private var steadyEmit : RadialDotEmitter;
		private var renderer : DisplayObjectRenderer;
		private var holder : Sprite;
		public static const DARK_BLUE : int = 0x266EB6;
		public static const LIGHT_BLUE : int = 0xA7FFFF;
		private var masker : Sprite;
		private var bg : Sprite;
		private var currX : *;
		private var currY : int;
		private var starEmit : StarEmitter;
		private var starRenderer : DisplayObjectRenderer;
		private var maxDots : Number = 10;
		private var maxStars : Number = 10;
		private var gradientBand : Sprite;
		private var currGradPos : Number = 125;

		public function FlintZone() {
			// import pngs

			holder = new Sprite();
			addBackground();

			holder.x = 100;
			// stage.stageWidth * .5 - 150;
			holder.y = 100;
			// stage.stageHeight * .5 - 125;
			addChild(holder);

			trace("FlintZone::()" + DARK_BLUE);

			/*	var bmp:Bitmap = new Bitmap(bmpD); */

			steadyEmit = new RadialDotEmitter();
			steadyEmit.addEventListener(ParticleEvent.PARTICLE_CREATED, onParticleCreated);
			steadyEmit.addEventListener(ParticleEvent.PARTICLE_DEAD, onParticleCreated);
			steadyEmit.x = 125;
			steadyEmit.y = 150;
			// renderer = new BitmapRenderer(new Rectangle(0,0,300,250));
			renderer = new DisplayObjectRenderer();
			renderer.addEmitter(steadyEmit);
			holder.addChild(renderer);
			steadyEmit.renderer = renderer;
			steadyEmit.start();

			starEmit = new StarEmitter();
			starEmit.addEventListener(ParticleEvent.PARTICLE_CREATED, onStarCreated);
			starEmit.addEventListener(ParticleEvent.PARTICLE_DEAD, onStarCreated);
			starEmit.x = 100;
			starEmit.y = 100;

			starRenderer = new DisplayObjectRenderer();
			starRenderer.addEmitter(starEmit);
			holder.addChild(starRenderer);
			starEmit.renderer = starRenderer;
			starEmit.start();

			starRenderer.filters = [new GlowFilter(0x7EFBFF, .6)];
				starRenderer.alpha = 0;
			// addChild(new Stats());

			var image : Bitmap = new Branding();
			holder.addChild(image);

			createMask();

			createGradientBand();
			 addMouseListener();
		}

		private function createGradientBand() : void {
			gradientBand = new Sprite();
			gradientBand.alpha = 0;
			holder.addChild(gradientBand);
			redrawGradientBand();
		}

		private function redrawGradientBand(event : MouseEvent = null) : void {
			if (event) trace("grad localX:" + event.localX);
			var newPos : Number = 150;
			if (event) {
				trace("mouse X:"+event.localX);
				var div300:Number = event.localX/300;
				trace("divided by 300:"+div300);
				var times255:Number = div300*255;
				trace("times 255:"+times255);
				newPos = times255;
				trace("new Pos:"+newPos);
			}
		//	currGradPos += ((newPos - currGradPos) / 2);

			var fillType : String = GradientType.LINEAR;
			var colors : Array = [0xff0000, 0xffffff, 0xff0000];
			var alphas : Array = [1, 1, 1];
			var ratios : Array ;
			if (!event) {
				ratios = [0, 125, 255];
			} else {
				ratios = [0, newPos, 255];
			}
			if (newPos<10){
				colors.shift();
				ratios.shift();
				alphas.shift();				
			}
			var matr : Matrix = new Matrix();

			matr.createGradientBox(400, 100, (Math.PI * .0), 0, 0);
			var spreadMethod : String = SpreadMethod.PAD;
			gradientBand.graphics.clear();
			gradientBand.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			gradientBand.graphics.drawRect(-50, 150, 400, 150);
		}

		private function onParticleCreated(event : ParticleEvent) : void {
			if (steadyEmit.particles.length < maxDots) {
				steadyEmit.x = Math.round(Math.random() * 300);
				steadyEmit.y = Math.round(Math.random() * 250);
				steadyEmit.counter = new Steady(10);
				steadyEmit.start();
			} else {
				steadyEmit.counter = new ZeroCounter();
			}
		}

		private function onStarCreated(event : ParticleEvent) : void {
			if (starEmit.particles.length < maxStars) {
				starEmit.x = Math.round(Math.random() * 300);
				starEmit.y = Math.round(Math.random() * 250);
				starEmit.counter = new Steady(10);
				// starEmit.start();
			} else {
				starEmit.counter = new ZeroCounter();
			}
		}

		private function addMouseListener() : void {
			holder.addEventListener(MouseEvent.MOUSE_MOVE, onMMove)
		}

		private function onMMove(event : MouseEvent) : void {
			trace("mmove");
		//	redrawBG(event);
			redrawGradientBand(event);
		}

		private function redrawBG(event : MouseEvent) : void {
			var fillType : String = GradientType.LINEAR;
			var colors : Array = [LIGHT_BLUE, DARK_BLUE];
			var alphas : Array = [1, 1];
			var ratios : Array = [100, 255];
			var matr : Matrix = new Matrix();
			var distX : Number = (event.stageX * .001) - currX;
			var moveX : Number = distX / 2;
			currX += moveX;
			var distY : Number = (event.stageY * .001) - currY;
			var moveY : Number = distY / 2;
			currY += moveY;

			matr.createGradientBox(500, 500, 45, currX, currY);
			var spreadMethod : String = SpreadMethod.PAD;
			bg.graphics.clear();
			bg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			bg.graphics.drawRect(0, 0, 300, 250);
		}

		private function createMask() : void {
			masker = new Sprite();
			masker.addChild(Drawing.drawBox(300, 250, 0xffff00));
			holder.addChild(masker);
			holder.mask = masker;
		}

		private function addBackground() : void {
			holder.addChild(new BG());
			/*
			
			bg = new Sprite();
			var fillType : String = GradientType.LINEAR;
			var colors : Array = [LIGHT_BLUE, DARK_BLUE];
			var alphas : Array = [1, 1];
			var ratios : Array = [40, 120];
			var matr : Matrix = new Matrix();
			matr.createGradientBox(500, 500, Math.PI * .47, 0, 0);
			currX = 50;
			currY = 100;
			var spreadMethod : String = SpreadMethod.PAD;
			bg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			bg.graphics.drawRect(0, 0, 300, 250);
			holder.addChild(bg);
			 * 
			 */
			// holder.addChild(Drawing.drawBox(300, 250, LIGHT_BLUE, 1, 5, 0xffffff, 1));
		}
	}
}
