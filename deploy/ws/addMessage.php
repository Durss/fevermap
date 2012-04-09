<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success.
	1 - SQL error
	2 - wrong parameter count
	100 - XML bad formated
	101 - page not found
	102 - token expired
	103 - user locked

	*/

	$resultCode = 0;
	if (isset($_POST["message"], $_POST["love"]) && !$user_locked) {
		try {
			$sql = "INSERT INTO `feverMessages` (`uid`, `date`, `message`, `love`) VALUES ('".mysql_real_escape_string($_SESSION['uid'])."', '".time()."', '".strip_tags(mysql_real_escape_string($_POST['message']))."', ".mysql_real_escape_string($_POST['love']).");";
			$Mysql->ExecuteSQL($sql);
		} catch (Erreur $e) {
			$resultCode = 1;
		}
	}else if($user_locked) {
		$resultCode = 402;
	}else{
		$resultCode = 2;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$resultCode."</result>\r\n";
	//$result .= "\t<message type='1' lock='true'><![CDATA[".md5($_POST["password"])." == ".$results[0]["password"]."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>