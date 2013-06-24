package alwaysAnimationTool.view {
	import flash.display.Shape;
	import graphics.Drawing;
	import flash.display.Sprite;

	/**
	 * @author acolling
	 */
	public class Dot extends Sprite {
		private var _radius : Number;
		private var _color : int;
		private var _graphic : Shape;
		public function Dot(radius:Number, color:int = 0xff8ffa, theAlpha:Number = 1) {
			_radius = radius;
			_color = color;
			alpha = theAlpha;
			init();
			
		}

		private function init() : void {
			_graphic = Drawing.drawCircle(_radius, _color);
			
		//	_graphic.x = 0-_radius*.5;
		//	_graphic.y = 0-_radius*.5;
			addChild(_graphic);
			
		}
		
		public function destroy():void{
			
			
		}
	}
}
