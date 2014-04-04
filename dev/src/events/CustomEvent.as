/* AS3
	Modified 2014 Galih Pranowo;
*/
package src.events 
{
	
	/**
	 *	CustomEvent;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 *
	 *	@author gapraart@gmail.com;
	 */
	
	import flash.display.*;
	import flash.events.*;
	
	public class CustomEvent extends Event 
	{
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const CUSTOM_EVENT : String = 'onCustomEvent';
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function CustomEvent ( inType : String = CUSTOM_EVENT, inParams : Object = null ) 
		{
			super( inType, true, true );
			
			m_type = inType;
			m_params = inParams;
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------

		private var m_type : String = CUSTOM_EVENT;
		private var m_params : Object = new Object();

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		public function get params () : Object 
		{
			return m_params;
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public override function clone () : Event
		{
			return new CustomEvent( m_type, m_params );
		}

		public override function get type () : String
		{
			return m_type;
		}
	}
}
