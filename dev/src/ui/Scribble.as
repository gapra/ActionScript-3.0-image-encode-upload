
package src.ui 
{
	
	/**
	 *	Scribble;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 */
	
	import flash.display.*;
	import flash.events.*;
	
	public class Scribble extends Sprite 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function Scribble () 
		{
			super();
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
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
		
		public function createEffect () : void
		{			
			reset();
			
			var t : Number = Math.round( Math.random() * 40 + 10 );
			
			for ( var i : Number = 0; i < t; i++ )
			{
				with ( this.graphics )
				{
					lineStyle( Math.random() * 3, Math.random() * 0xFFFFFF, Math.random() );
					curveTo( Math.random() * stage.stageWidth, Math.random() * stage.stageHeight, Math.random() * stage.stageWidth, Math.random() * stage.stageHeight );
				}
			}
		}
		
		public function reset () : void
		{
			this.graphics.clear();
		}
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
	}
}
