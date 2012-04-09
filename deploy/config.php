<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Content-type: text/xml");
	
	if (isset($_GET["lang"]) && file_exists("xml/labels_".strtolower($_GET["lang"]).".xml")) {
		echo (file_get_contents("xml/labels_".strtolower($_GET["lang"]).".xml"));
	}else {
		echo (file_get_contents("xml/labels_fr.xml"));
	}
?>