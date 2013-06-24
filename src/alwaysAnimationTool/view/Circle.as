package alwaysAnimationTool.view {
	import flash.display.DisplayObject;
	import graphics.Drawing;

	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author acolling
	 */
	public class Circle extends Sprite {
		private var _totalDots : uint;
		private var _radius : uint;
		private var _dotRadius : uint;
		private var _dots : Array;
		private var _dotHolder : Sprite;
		private var _dotColor : uint;
		private var _showCircles : Boolean;
		private var _dotAlpha : Number;

		// total dots, radius, dot radius
		public function Circle(dots : uint, radius : uint, dotRadius : uint, dotColor : uint = 0xffffff, showCircles:Boolean = false, dotAlpha:Number = 0) {
			_showCircles = showCircles;
			_totalDots = dots;
			_dotAlpha = dotAlpha;
			_radius = radius;
			_dotRadius = dotRadius;
			_dots = [];
			_dotColor = dotColor;
			_dotHolder = new Sprite();

			addChild(_dotHolder);

			init();
		}

		private function init() : void {
			if (_showCircles) {
				var bg : Shape = Drawing.drawCircle(_radius, 0xffffff * Math.random());
				bg.alpha = .2;
				addChild(bg);
			}
			while (_dotHolder.numChildren > 0) {
				_dotHolder.removeChildAt(0);
			}

			var increment : Number = (Math.PI * 2) / _totalDots;
			for (var i : int = 0; i < _totalDots; i++) {
				var dot : Dot = new Dot(_dotRadius, _dotColor, _dotAlpha);
				dot.x = (Math.cos(increment * i) * _radius);
				dot.y = (Math.sin(increment * i) * _radius);
				_dotHolder.addChild(dot);
			}
		}

		public function getDots() : Array {
			var dots:Array = [];
			for (var i : int = 0; i < _totalDots; i++) {
				var dot:DisplayObject = _dotHolder.getChildAt(i);
				dots.push(dot);
			}
			return dots;
		}
	}
}
