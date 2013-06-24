package alwaysAnimationTool {
	import graphics.Drawing;
	import flash.display.Bitmap;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.TweenMax;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.text.TextField;

	import utils.TextFieldUtils;

	import alwaysAnimationTool.view.ControlUI;
	import alwaysAnimationTool.view.DotsDisplay;
	import alwaysAnimationTool.view.SketchParams;

	import hires.debug.Stats;

	import plugins.ShakeEffect;

	import com.greensock.plugins.TweenPlugin;

	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	public class AlwaysAnimationTool extends Sprite {
		public static const FONT_NAVY : int = 0x203174;
		public static const FONT_BLUE : int = 0x008bc1;
		private static const FONT_SIZE : uint = 28;
		private static const BANNER_WIDTH : Number = 300;
		private static const BANNER_HEIGHT : Number = 250;
		private static const COPY_1 : String = "A new\rrevolutionary\rmaterial";
		private static const COPY_2 : String = "That absorbs\r10x its weight";
		private static const COPY_3 : String = "Yet you barely\rfeel it";
		
		private static const FADE_IN_COPY_TIME : Number = 1;
		[Embed(source="../presets/1.preset", mimeType="application/octet-stream")]
		private var _Preset1 : Class;
		[Embed(source="../presets/2.preset", mimeType="application/octet-stream")]
		private var _Preset2 : Class;
		[Embed(source="../presets/3.preset", mimeType="application/octet-stream")]
		private var _Preset3 : Class;
		[Embed(source="../presets/4.preset", mimeType="application/octet-stream")]
		private var _Preset4 : Class;
		
		//BITMAPS
		[Embed(source="../assets/bg.png")]
		private var _BG : Class;
		[Embed(source="../assets/frontEquity.png")]
		private var _FrontEquity : Class;
		[Embed(source="../assets/finalCTA.png")]
		private var _FinalCTA : Class;
		[Embed(source="../assets/finalPack.png")]
		private var _FinalPack : Class;
		[Embed(source="../assets/ribbon.png")]
		private var _Ribbon : Class;
		
		private var _controls : ControlUI;
		private var _holder : Sprite;
		private var _display : DotsDisplay;
		private var _bannerWidth : int = 300;
		private var _bannerHeight : int = 250;
		private var _tf : TextField;
		private var _format : TextFormat;
		private var copy : Array;
		private var copyIndex : uint;
		private var _copyHolder : Sprite;
		private var _finalCTA : Sprite;
		private var _frontEquity : Sprite;
		private var _packshot : Sprite;
		private var _packshotHolder : Sprite;

		public function AlwaysAnimationTool() {
			(stage) ? initApp() : addEventListener(Event.ADDED_TO_STAGE, initApp);
		}

		private function initApp(e : Event = null) : void {
			MyFonts;
			TweenPlugin.activate([ShakeEffect, GlowFilterPlugin]);
			

			if (e) removeEventListener(Event.ADDED_TO_STAGE, initApp);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_holder = new Sprite();
			_display = new DotsDisplay();
			_display.addChildAt(new _BG(), 0);
			var ribbon:Bitmap = new _Ribbon();
			ribbon.smoothing = true;
			_packshotHolder = new Sprite();
			_packshotHolder.x = 80;
			_packshotHolder.y = 80;
			_packshot = new Sprite();
			_display.addChildAt(ribbon, _display.numChildren-1);
			_packshotHolder.addChild(_packshot);			
			var finalPack:Bitmap = new _FinalPack();
			finalPack.smoothing = true;
			_packshot.addChild(finalPack);
			_packshot.scaleX = _packshot.scaleY = .7;
			_display.addChildAt(_packshotHolder, _display.numChildren-1);
			_display.x = 140;
			_display.y = 50;

			_controls = new ControlUI(_display);
		//	_controls.x = -230;
		//	_controls.y = -170;
			_controls.visible = false;
			var stats : Stats = new Stats();
			stats.x = _display.x + _bannerWidth + 300;
			stats.y = _display.y + _bannerHeight + 00;
			//addChild(stats);

			_holder.addChild(_display);
			_holder.addChild(_controls);
			var masker:Sprite = new Sprite();
			masker.x = 140;
			masker.y = 50;
			masker.addChild(Drawing.drawBox(300, 250, 0xff00ff));
			_holder.addChild(masker);
			_holder.mask = masker;

			addChild(_holder);
			initCopy();
			createTextField();
			addListeners();
			valueUpdatedListener(new Event("init"));
			createPresets();
			initializeAnim();
			startAnimation();
		}

		private function initCopy() : void {
			copy = [];
			copyIndex = 0;
			copy.push(COPY_1, COPY_2, COPY_3);
			
		}

		private function setCopy(index : uint) : void {
			_tf.text = copy[index];
			_tf.x = (BANNER_WIDTH * .5) - (_tf.width * .5);
			_tf.y = (BANNER_HEIGHT * .5) - (_tf.height * .5);
		}

		private function createTextField() : void {
			_tf = TextFieldUtils.createTextField(true, false, 250);
		//	_tf.border = true;	
			_format = TextFieldUtils.createTextFormat("iTCAvantGardeGothic", FONT_NAVY, FONT_SIZE,0,false,-33);
			_format.align = TextFormatAlign.CENTER;
			_tf.defaultTextFormat = _format;
		
			
			_copyHolder = new Sprite();
			_copyHolder.alpha = 0;
			_copyHolder.addChild(_tf);
			_display.addChild(_copyHolder);
			setCopy(copyIndex);
		}

		private function initializeAnim() : void {
			_controls.sketchParams = _controls.presets[0];
			_controls.valueUpdated();
		}

		private function startAnimation() : void {
			trace("AlwaysAnimationTool.startAnimation()  ");
			fadeCopy(1);
			TweenMax.delayedCall(2, animation1);
		}

		private function animation1() : void {
			trace("AlwaysAnimationTool.animation1()  ");
			//animate the balls to the middle
			_controls.tweenToValues(_controls.presets[1]);
			//fade copy out and show new copy  'That abosrbs 10x.....'
			copyIndex = 1;
			fadeCopy(0, copyIndex);
			//delayed call to the next preset and start making text thicker
			TweenMax.delayedCall(1, smallerDotsPreset);
			TweenMax.to(_copyHolder, 7, {glowFilter:{color:FONT_NAVY, alpha:.4, blurX:3, blurY:3, strength:3}});
			
		}

		private function smallerDotsPreset() : void {
			_controls.tweenToValues(_controls.presets[2]);
			TweenMax.delayedCall(1, preExplosionPreset );
			
		}
		
		private function preExplosionPreset():void{
			_controls.tweenToValues(_controls.presets[3]);
			_controls.startShake();
		}

		//if a new copy index is passed then the function will fade the new copy in immediately
		private function fadeCopy(i : Number, newCopyIndex:int = -1, newColor:int = 0x0) : void {
			(newCopyIndex<0)?TweenMax.to(_copyHolder, FADE_IN_COPY_TIME, {alpha:i}):
			TweenMax.to(_copyHolder, FADE_IN_COPY_TIME, {alpha:i, onComplete:function():void{
				if (newColor != 0x0){
					TweenMax.to(_copyHolder, 0, {tint:newColor});
				}
				setCopy(newCopyIndex);
				fadeCopy(1);
			}});
		}

		private function createPresets() : void {
			registerClassAlias("alwaysAnimationTool.view", SketchParams);
			// preset 1
			var data1 : ByteArray = new _Preset1();
			var preset1 : * = data1.readObject();
			var tmp1 : SketchParams = preset1 as SketchParams;
			// preset 2
			var data2 : ByteArray = new _Preset2();
			var preset2 : * = data2.readObject();
			var tmp2 : SketchParams = preset2 as SketchParams;
			// preset 1
			var data3 : ByteArray = new _Preset3();
			var preset3 : * = data3.readObject();
			var tmp3 : SketchParams = preset3 as SketchParams;
			// preset 2
			var data4 : ByteArray = new _Preset4();
			var preset4 : * = data4.readObject();
			var tmp4 : SketchParams = preset4 as SketchParams;
			// add to presets
			_controls.presets.push(tmp1);
			_controls.presets.push(tmp2);
			_controls.presets.push(tmp3);
			_controls.presets.push(tmp4);
			// update display
			_controls.updateAnimList(_controls.presets);
			_controls.valueUpdated();
		}

		private function addListeners() : void {
			_controls.addEventListener("valueUpdated", valueUpdatedListener);
			_controls.addEventListener("explode", explodeListener);
			_controls.addEventListener("removeParticles", removeParticlesListener);
		}

		private function removeParticlesListener(e : Event) : void {
			// _display.removeParticles();
		}

		private function valueUpdatedListener(e : Event) : void {
			_display.valuesSet(_controls.sketchParams);
		}

		private function explodeListener(e : Event) : void {
			TweenMax.to(_copyHolder, 0, {glowFilter:{color:FONT_NAVY, alpha:0, blurX:0, blurY:0, strength:0}});
			_display.removeAllFilters();
			
			_display.explode();
			//fade out center glow
			_display.fadeOutCenterGlow();//coud use preset..
			//swap copy and color
		//	fadeCopy(0);//,2, FONT_BLUE);
			TweenMax.to(_copyHolder, .4, {alpha:0});
			TweenMax.delayedCall(2, showNewBlueCopy);
		}

		private function showNewBlueCopy() : void {
			trace("AlwaysAnimationTool.showNewBlueCopy()  ");
			TweenMax.to(_copyHolder, 0, {tint:FONT_BLUE});
			
			setCopy(2)
			fadeCopy(1);
			TweenMax.delayedCall(3, fadeOutFinalCopy);
		}

		private function fadeOutFinalCopy() : void {
			fadeCopy(0);
			TweenMax.delayedCall(1, fadeInFinalCTA);
		}

		private function fadeInFinalCTA() : void {
			_finalCTA = new Sprite();
			_finalCTA.alpha = 0;
			_finalCTA.addChild(new _FinalCTA());
			_display.addChild(_finalCTA);
			TweenMax.to(_finalCTA, 1, {alpha:1})
			TweenMax.to(_packshot, 1, {scaleX:1, scaleY:1, x:-80, y:-80});
		}
	}
}
