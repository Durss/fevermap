<?php

	require_once("RequestEncrypter.php");
	
	if (isset($_POST["data"])) {
		$decrypt = RequestEncrypter::decrypt($_POST["data"]);
	}else {
		$decrypt = array();
	}
	
	//Parses the results and store them in the $_POST vars.
	foreach ($decrypt as $key => $value) {
		$_POST[$key] = $value;
	}
	
	if(isset($_GET["data"])) {
		$decrypt = RequestEncrypter::decrypt($_GET["data"]);
		
		//Parses the results and store them in the $_GET vars.
		foreach ($decrypt as $key => $value) {
			$_GET[$key] = $value;
			$_POST[$key] = $value;
		}
	}

?>