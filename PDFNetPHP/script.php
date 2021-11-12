<?php

try {
	$path_to_file = $argv[1];
	$file_contents = file_get_contents($path_to_file);
	$file_contents = str_replace("<?php\n","<?php\nnamespace pdftron;\n",$file_contents);
	file_put_contents($path_to_file,$file_contents);

} catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
}
?>

