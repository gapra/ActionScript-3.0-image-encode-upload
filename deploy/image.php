<?PHP
$target_path = $_REQUEST[ 'path' ];
$target_path = $target_path . basename( $_FILES[ 'Filedata' ][ 'name' ] ); 

if ( move_uploaded_file( $_FILES[ 'Filedata' ][ 'tmp_name' ], $target_path ) ) 
{
     echo "The file " . basename( $_FILES[ 'Filedata' ][ 'name' ] ) . " has been uploaded;";
} 
else
{
     echo "There was an error uploading the file, please try again!";
}
?>
