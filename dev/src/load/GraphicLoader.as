/* AS3
	Copyright 2008 findsubstance;
*/
package src.load
{
	
	/**
	 *	GraphicLoader;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 *
	 *	@author shaun.tinney@findsubstance.com;
	 *	@since  02.13.2008;
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import src.events.CustomEvent;
	
	public class GraphicLoader extends Loader 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const ON_LOAD_PROGRESS : String = 'onLoadProgress';
		public static const ON_LOAD_COMPLETE : String = 'onLoadComplete';
		public static const ON_MODE_CHANGED : String = 'onModeChanged';
		
		public static const MODE_ERROR : int = -2;
		public static const MODE_EMPTY : int = -1;
		public static const MODE_LOADING : int = 0;
		public static const MODE_COMPLETE : int = 1;
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function GraphicLoader () 
		{
			super();
			
			this.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
			this.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaded );
			this.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHttpStatus );
			this.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, catchError );
			this.contentLoaderInfo.addEventListener( ErrorEvent.ERROR, catchError );
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------

		// vars;
		private var m_mode : int = MODE_EMPTY;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		public function get mode () : int
		{
			return m_mode;
		}
		
		public function set mode ( inMode : int ) : void
		{			
			m_mode = inMode;
			
			dispatchEvent( new CustomEvent( ON_MODE_CHANGED, { mode : m_mode } ) ); 
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		
		public function loadURL ( inURL : String ) : void
		{
			this.mode = MODE_LOADING;
			
			this.unload();
			
			super.load( new URLRequest( inURL ) );
		}
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function onProgress ( e : ProgressEvent ) : void
		{			
			dispatchEvent( new CustomEvent( ON_LOAD_PROGRESS, { percent : normalize( e.bytesLoaded / e.bytesTotal ) } ) );
		}
		
		private function onLoaded ( e : Event ) : void 
		{
			this.mode = MODE_COMPLETE;
			
			dispatchEvent( new CustomEvent( ON_LOAD_COMPLETE, { loaded : this.content } ) );
		}
		
		protected function catchError ( e : * ) : void 
		{
			this.mode = MODE_ERROR;
			
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, true ) );
		}
		
		protected function onHttpStatus ( e : HTTPStatusEvent )
		{
			// http status event;
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		private function normalize ( inValue : Number ) : Number
		{
			var v : Number = inValue;
			
			if ( v > 1 ) v = 1;
			if ( v < 0 ) v = 0;
			
			v = Number( v.toFixed( 3 ) );
			
			return v;
		}
	}
}
