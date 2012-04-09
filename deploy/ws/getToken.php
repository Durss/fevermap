<?php
	include_once("../RequestEncrypter.php");
	
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<rand>".rand(-999999,999999)."</rand>\r\n";
	$result .= "\t<token>".time()."</token>\r\n";
	$result .= "</root>\r\n";
	echo RequestEncrypter::encrypt($result);
?>