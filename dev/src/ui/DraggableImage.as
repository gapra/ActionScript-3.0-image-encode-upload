/* AS3
	Copyright 2008 findsubstance;
*/
package src.ui 
{
	
	/**
	 *	DraggableImage;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 *
	 *	@author shaun.tinney@findsubstance.com;
	 *	@since  03.13.2008;
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import gs.TweenFilterLite;
	
	public class DraggableImage extends Sprite 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function DraggableImage ( inImage : Bitmap ) 
		{
			super();
			
			this.buttonMode = true;
			
			this.addChild( inImage );
			
			this.addEventListener( MouseEvent.MOUSE_DOWN, handleMouseAction );
			this.addEventListener( MouseEvent.MOUSE_UP, handleMouseAction );
			this.addEventListener( Event.ADDED_TO_STAGE, onAdded );

			this.alpha = 0;
			
			TweenFilterLite.to( this, .5, { alpha : 1 } );
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------
		
		// display items;

		// vars;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		public function get dragBounds () : Rectangle
		{
			if ( stage == null ) return new Rectangle();
			
			return new Rectangle( 0, 0, stage.stageWidth - this.width, stage.stageHeight - this.height );
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function handleMouseAction ( e : MouseEvent ) : void
		{			
			var a : Number = Number( e.type == MouseEvent.MOUSE_UP ) * .5 + .5;
			
			TweenFilterLite.to( this, .5, { alpha : a } );
			
			switch ( e.type )
			{
				case MouseEvent.MOUSE_DOWN
				:
					this.startDrag( false, dragBounds );
					
				break;
					
				case MouseEvent.MOUSE_UP
				:
					onKillDrag();
					
				break;
			}
		}
		
		private function onKillDrag ( e : * = null ) : void
		{
			stopDrag();
			
			TweenFilterLite.to( this, .5, { alpha : 1 } );
		}
		
		private function onAdded( e : Event ) : void
		{
			stage.addEventListener( Event.MOUSE_LEAVE, onKillDrag );
			stage.addEventListener( MouseEvent.MOUSE_UP, onKillDrag );
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
	}
}
