package particles.SampleApp {
	import org.flintparticles.common.displayObjects.Star;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.counters.*;
	import org.flintparticles.common.displayObjects.Dot;
	import org.flintparticles.common.initializers.*;
	import org.flintparticles.twoD.actions.*;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.*;
	import org.flintparticles.twoD.zones.*;

	import flash.display.BlendMode;
	import flash.display.DisplayObject;

	/**
	 * @author acolling
	 */
	public class StarEmitter extends Emitter2D {
		
		
		[Embed(source="../../../../images/sparkle1.gif", mimeType="image/png")]
    	public var Sparkle1:Class;
		[Embed(source="../../../../images/sparkle2.gif", mimeType="image/png")]
    	public var Sparkle2:Class;
		[Embed(source="../../../../images/sparkle3.gif", mimeType="image/png")]
    	public var Sparkle3:Class;
		[Embed(source="../../../../images/sparkle4.gif", mimeType="image/png")]
    	public var Sparkle4:Class;
		[Embed(source="../../../../images/branding.png", mimeType="image/png")]
    	public var Branding:Class;
		
		
		public var _renderer : DisplayObject;
		
		public function StarEmitter() {
			
			counter = new Steady(5);
			//addInitializer(new SharedImage(new Dot(10,0xff0000, BlendMode.LIGHTEN)));
			addInitializer( new ImageClass( Star, [1] ) );
			
			addInitializer(new ScaleAllInit(1,5));
			addInitializer(new CollisionRadiusInit(5));
			addInitializer(new AlphaInit(.7,1));
			
		//	var zone2:PointZone = new PointZone( new Point( 0, -33 ) );
		//	var velocity:Velocity = new Velocity( zone2 );
		//	addInitializer( velocity );
			
			//addInitializer(new Lifetime(10));
			
			//addInitializer(new Velocity(new RectangleZone(-100,-100,100,100)));
			addAction(new Move());
		//	addAction(new ScaleImage(1,10));  
			addAction( new DeathZone( new RectangleZone( -10, -10, 320, 260 ), true ) );
			addAction( new RandomDrift( 60, 60) );
			
			
		//	addAction(new AntiGravity(100, 500, 400,10));
			//addAction(new BoundingBox(-100, -100, 100, 100));			
		//	createGravWells();
		}

		private function createGravWells() : void {
			for (var i : int = 0; i < 100; i++) {
				var well:GravityWell = new GravityWell(1, i*5, 200, 50);
				addAction(well);
				
			}
		}

		public function get renderer() : DisplayObject {
			return _renderer;
		}

		public function set renderer(renderer : DisplayObject) : void {
			_renderer = renderer;
			addAction(new MouseAntiGravity(15, _renderer, 5));
		}
	}
}
