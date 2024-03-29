package away3d.core.draw
{
    import away3d.core.base.*;
    import away3d.core.render.*;
                               
    import flash.display.BitmapData;

    /**
    * Unscaled bitmap drawing primitive
    */
    public class DrawBitmap extends DrawPrimitive
    {
    	/**
    	 * The bitmapData object used as the bitmap primitive texture.
    	 */
        public var bitmap:BitmapData;

        public var screenvertex:ScreenVertex;
        
		/**
		 * @inheritDoc
		 */
        public override function calc():void
        {
            screenZ = screenvertex.z;
            minZ = screenZ;
            maxZ = screenZ;
            minX = screenvertex.x - bitmap.width/2;
            minY = screenvertex.y - bitmap.height/2;
            maxX = screenvertex.x + bitmap.width/2;
            maxY = screenvertex.y + bitmap.height/2;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear():void
        {
            bitmap = null;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
        	source.session.renderBitmap(bitmap,screenvertex);
        }
        
        //TODO: correct function for contains in DrawBitmap
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Number, y:Number):Boolean
        {   
            return true;
        }
    }
}
