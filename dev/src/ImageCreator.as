/* AS3
	Copyright 2008 findsubstance;
*/
package src 
{
	
	/**
	 *	ImageCreator;
	 *
	 *	@langversion ActionScript 3.0;
	 *	@playerversion Flash 9.0;
	 *
	 *	@author shaun.tinney@findsubstance.com;
	 *	@since  03.12.2008;
	 *	
	 *	@license http://creativecommons.org/licenses/by-nc-sa/3.0/
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.system.*;
	
	import src.events.*;
	import src.image.*;
	import src.file.*;
	import src.load.*;
	import src.ui.*;
	
	import gs.TweenFilterLite;
	
	public class ImageCreator extends Sprite 
	{
		
		//--------------------------------------
		// CUSTOM VARIABLES YOU'LL NEED TO ENTER
		//--------------------------------------
		
		private var m_basePath  : String = 'http://yourserver.com/project/';			// set this to your web server path 'http://YOURSITE.com/';
		private var m_uploadPath : String = 'uploads/';										// set this to the folder on your server where you will allow images to be uploaded ( folder permissions must be set to 777 );
		private var m_outputPath : String = 'output/';										// set this to the folder on your server where images should be created; ( folder permissions must be set to 777 );
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		public function ImageCreator () 
		{
			// allow script access;
			Security.allowDomain( '*' );			// replace * with your domain;
			Security.allowInsecureDomain( '*' );	// replace * with your domain;
			
			// determine whether the swf is being accessed from the web or your local hard drive;
			m_isLocal = false;
			
			// hide image creation options;
			creating.visible = false;
			creating.alpha = 0;
			
			// set up file manager & basic interaction listeners on slight delay;
			TweenFilterLite.delayedCall( 0.5, init );
		}
		
		//--------------------------------------
		//  CLASS VARIABLES
		//--------------------------------------

		// display items;
		public var upload : UIButton;						// upload button on .fla stage;
		public var download : UIButton;						// download button on .fla stage;
		public var create : UIButton;						// create button on .fla stage;
		public var scribble : UIButton;						// scrubble button on .fla stage;
		public var clear : UIButton;						// clear button on .fla stage;
		public var creating : Sprite;						// creating screen ( shows while image is being saved to sever );
		
		// output container;
		private var m_output : Sprite = new Sprite();		// container for image;
		private var m_mask : Sprite = new Sprite();			// mask for image container;
		private var m_progress : Sprite = new Sprite();		// upload / download indicator;
		private var m_effect : Scribble;					// covers image with random effect;

		// vars;
		private var m_isLocal : Boolean;					// determines if swf is on web server or local drive;
		private var m_fileMgr : FileManager;				// manages the opening & upload of local files;
		private var m_imagePHP : String = 'image.php';		// file that will manage image upload on your server;
		private var m_finalImage : String;					// final name of file on creation;
		private var m_imageQuality : Number = 90;			// jpeg or png export quality;
		private var m_capture : Sprite;						// set this equal to the sprite or movie clip that you wish to capture ( set to stage for entire movie );
		private var m_downloader : GraphicLoader;			// handles image download ( after upload is complete );
		private var m_imageExtension : String = '.jpg';		// jpeg image extension;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		/**
		*	returns upload php file path based on whether or not the swf is a local publish or hosted on a web server;	
		**/
		public function get uploadPath () : String
		{
			return m_basePath + m_imagePHP;
		}
		
		/**
		*	returns image creation php file path based on whether or not the swf is a local publish or hosted on a web server;	
		**/
		public function get createPath () : String
		{
			return m_basePath + m_imagePHP;
		}
		
		/**
		*	returns image creation php file path based on whether or not the swf is a local publish or hosted on a web server;	
		**/
		public function get downloadPath () : String
		{
			return m_basePath + m_uploadPath;
		}
		
		/**
		*	returns image creation php file path based on whether or not the swf is a local publish or hosted on a web server;	
		**/
		public function get finalImagePath () : String
		{
			return m_basePath + m_outputPath + m_finalImage + m_imageExtension;
		}
		
		/**
		*	returns container for image capture container;
		**/
		public function get captureContainer () : Sprite
		{
			return m_capture;
		}
		
		/**
		*	sets container for image capture container;
		**/
		public function set captureContainer ( inContainer : Sprite ) : void
		{
			m_capture = inContainer;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		/**
		*	browse for image files on click of upload button;	
		**/
		private function onBrowse ( e : MouseEvent ) : void
		{
			m_fileMgr.browse();
		}
		
		/**
		*	run the image capture function on release of the create button;	
		**/
		private function onCaptureImage ( e : MouseEvent ) : void
		{			
			// make sure there is content to capture;
			if ( captureContainer.width <= 1 && captureContainer.height <= 1 ) throw new Error( 'ERROR : no content to capture;' );
			
			// show image creation message;
			TweenFilterLite.to( creating, 1, { autoAlpha : 1 } );
			
			// create image;
			captureImage();
		}
		
		/**
		*	track image upload progress;
		**/
		private function onUploadProgress ( e : CustomEvent ) : void
		{
			trace( 'image uploading : ' + e.params.percent );
			
			m_progress.scaleX = e.params.percent;
		}
		
		/**
		*	fires when image upload is complete;		
		**/
		private function onImageUploaded ( e : CustomEvent ) : void
		{			
			var dPath : String = String( downloadPath + e.params.fileName );
			
			trace( 'image ready for download at : ' + dPath );
			
			m_downloader.loadURL( dPath );
		}
		
		/**
		*	track image download progress;		
		**/
		private function onDownloadProgress ( e : CustomEvent ) : void
		{
			trace( 'image downloading : ' + e.params.percent );
			
			m_progress.scaleX = 1 - e.params.percent;
		}
		
		/**
		*	fires on image download is complete;		
		**/
		private function onImageDownloaded ( e : CustomEvent ) : void
		{
			trace( 'image downloaded' );
			
			// get image from loader;
			var clip : DraggableImage = new DraggableImage( new Bitmap( e.params.loaded.bitmapData.clone() ) );

			// add the image to the stage;
			captureContainer.addChildAt( clip, captureContainer.getChildIndex( m_effect ) );
			
			// show create / clear options;
			showOptions();
		}
		
		/**
		*	fires after image is successfully created on your server;		
		**/
		private function onImageCreated ( e : Event ) : void 
		{
			trace( 'image created : ' + e );
			
			// hide image creation message;
			TweenFilterLite.to( creating, 1, { autoAlpha : 0 } );
			
			// show download button;
		 	TweenFilterLite.to( download, 0.5, { autoAlpha : 1 } );
		
			// show download dialog for flash player versions < 10;
			onDownloadImage();
		} 
		
		/**
		*	attempts to download image to local computer;
		**/
		private function onDownloadImage ( e : MouseEvent = null ) : void
		{			
			m_fileMgr.download( finalImagePath, m_finalImage + m_imageExtension );
		}
		
		/**
		*	fires if there is an error creating the image;		
		**/
		private function onImageCreationError ( e : * ) : void 
		{
			trace( 'error : ' + e );
		}
		
		/**
		*	fires if there is an error during upload;		
		**/
		private function onUploadError ( e : CustomEvent ) : void
		{
			trace( 'upload error' );
		}
		                                                  
		/**
		*	fires if there is an error during download;		
		**/
		private function onDownloadError ( e : ErrorEvent ) : void
		{
			trace( 'download error' );
		}
		
		/**
		*	downloads image to swf;
		**/
		private function onGetCapturedImage ( e : MouseEvent ) : void
		{
			m_fileMgr.download( finalImagePath, m_finalImage + m_imageExtension );
		}
		
		/**
		*	creates random scribble all over stage;	
		**/
		private function onScribble ( e : MouseEvent ) : void
		{
			m_effect.createEffect();
			
			showOptions();
		}
		
		/**
		*	clears any image in the capture conatiner, and resets scribble graphics;	
		**/
		private function onClearAll ( e : MouseEvent ) : void
		{
			// remove all child object ( except effect clip ) from capture area;
			while ( captureContainer.getChildAt( 0 ) is DraggableImage ) delete captureContainer.removeChildAt( 0 );
			
			// reset the scribbles;
			m_effect.reset();
			
			// hide create / clear options;
			hideOptions();
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		/**
		*	set up file manager / button listeners;	
		**/
		private function init () : void
		{			
			// add output container to stage at 0,0;
			addChildAt( m_output, 0 );
			
			// check to make sure stage is available ( which it wouldn't be if this class were instantiated from another class );
			if ( stage != null ) 
			{
				// set up stage;
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				
				// create image mask that matches the stage height & width;
				with ( m_mask.graphics )
				{
					beginFill( 0x000000 );
					drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
				}
				
				var border : Sprite = new Sprite();
				
				// draw border around stage;
				with ( border.graphics )
				{
					lineStyle( 0, 0x000000 );
					drawRect( 0, 0, stage.stageWidth - 1, stage.stageHeight - 1 );
				}
				
				addChildAt( border, numChildren - 1 );
			}
			
			// create progress indicator;
			with ( m_progress.graphics )
			{
				beginFill( 0x000000 );
				drawRect( 0, 0, upload.width, 1 );
			}
			
			addChild( m_progress );
			
			m_progress.x = upload.x;
			m_progress.y = upload.y + upload.height + 2;
			
			// set container to use as image capture area;
			captureContainer = m_output;
			
			// set capture container mask;
			captureContainer.mask = m_mask;
			
			// add effect to image;
			m_effect = new Scribble();
			
			captureContainer.addChild( m_effect );
			
			// show upload / scribble buttons;
			upload.show();
			scribble.show();
			
			// set progress bar to zero scale;
			m_progress.scaleX = 0;
			
			// set up file manager;
			m_fileMgr = new FileManager( uploadPath, m_uploadPath );
			m_fileMgr.addEventListener( FileManager.ON_PROGRESS, onUploadProgress );
			m_fileMgr.addEventListener( FileManager.ON_UPLOAD_ERROR, onUploadError );
			m_fileMgr.addEventListener( FileManager.ON_IMAGE_UPLOADED, onImageUploaded );
			
			// listen to buttons;
			upload.addEventListener( MouseEvent.CLICK, onBrowse );
			create.addEventListener( MouseEvent.CLICK, onCaptureImage );
			download.addEventListener( MouseEvent.CLICK, onDownloadImage );
			scribble.addEventListener( MouseEvent.CLICK, onScribble );
			clear.addEventListener( MouseEvent.CLICK, onClearAll );
			
			// ensure that the top left corner of the draw area is included in the draw calculations by drawing an invisible 1px box at 0,0;
			var corner : Sprite = new Sprite();
			
			// draw box;
			with ( corner.graphics )
			{
				beginFill( 0xFFFFFF, 0 );
				drawRect( 0, 0, 1, 1 );
			}
			
			// add corner piece to container;
			captureContainer.addChild( corner );
			
			// set up loader;
			m_downloader = new GraphicLoader();
			m_downloader.addEventListener( GraphicLoader.ON_LOAD_PROGRESS, onDownloadProgress );
			m_downloader.addEventListener( GraphicLoader.ON_LOAD_COMPLETE, onImageDownloaded );
			m_downloader.addEventListener( ErrorEvent.ERROR, onDownloadError );
			
			hideOptions();
		}
		
		/**
		*	perform image capture and upload to server;
		**/
		private function captureImage () : void
		{			
			// set up a new bitmapdata object that matches the dimensions of the captureContainer;
			var bmd : BitmapData = new BitmapData( m_mask.width, m_mask.height, true, 0xFFFFFFFF );
			
			// draw the bitmapData from the captureContainer to the bitmapData object;
			bmd.draw( captureContainer, new Matrix(), null, null, null, true );
			
			// create a new JPEG byte array with the adobe JPEGEncoder Class;
			var byteArray : ByteArray = new JPGEncoder( m_imageQuality ).encode( bmd );
			
			// create and store the image name;
			m_finalImage = getUniqueName();
			
			// set up the request & headers for the image upload;
			var urlRequest : URLRequest = new URLRequest();
			urlRequest.url = createPath + '?path=' + m_outputPath;
			urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = UploadPostHelper.getPostData( m_finalImage + m_imageExtension, byteArray );
			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );

			// create the image loader & send the image to the server;
			var urlLoader : URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener( Event.COMPLETE, onImageCreated );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onImageCreationError );
			urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onImageCreationError );
			urlLoader.load( urlRequest );
		}
		
		/**
		*	returns new string representing the month, day, hour, minute and millisecond of creation for use as the image name;	
		*/
		private function getUniqueName () : String
		{
			var d : Date = new Date();
			
			return d.getMonth() + 1 + '' + d.getDate() + '' + d.getHours() + '' + d.getMinutes() + ''  + d.getMilliseconds();
		}
		
		/**
		*	show create / clear options;	
		**/
		private function showOptions () : void
		{
			create.show();
			clear.show();
		}
		
		/**
		*	hide create / clear options;	
		**/
		private function hideOptions () : void
		{
			create.hide();
			clear.hide();
			download.hide();
		}
	}
}
