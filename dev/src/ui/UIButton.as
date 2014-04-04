
package src.ui 
{
	
	/**
	 *	UIButton;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 */
	
	import flash.display.*;
	import flash.events.*;
	import gs.TweenFilterLite;
	
	public class UIButton extends Sprite 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function UIButton () 
		{
			super();
			
			this.buttonMode = true;
			this.mouseChildren = false;
			this.visible = false;
			this.alpha = 0;
			
			this.addEventListener( MouseEvent.MOUSE_OVER, handleMouseAction );
			this.addEventListener( MouseEvent.MOUSE_OUT, handleMouseAction );
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------
		
		// display items;

		// vars;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public function show () : void
		{
			if ( !this.visible ) this.alpha = 0;
			
			TweenFilterLite.to( this, .5, { autoAlpha : 1 } );
		}

		public function hide () : void
		{
			this.alpha = 0;
			this.visible = false;
		}
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function handleMouseAction ( e : MouseEvent ) : void
		{
			var a : Number = .8 + Number( e.type == MouseEvent.MOUSE_OUT ) * .2;
			
			TweenFilterLite.to( this, .25, { alpha : a } );
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
	}
}
