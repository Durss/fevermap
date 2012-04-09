<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	102 - token has expired

	*/

	$res = 0;
	$data = "";
	try {
		$sql = "SELECT * FROM feverUsers WHERE uid=".$_SESSION["uid"];
		$results = $Mysql->TabResSQL($sql);
		$world = $results[0]['world'];
		$data = $results[0]['data'.$world];
	} catch (Erreur $e) {
		$res = 1;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$res."</result>\r\n";
	$result .= "\t<data><![CDATA[".$data."]]></data>\r\n";
	//$result .= "\t<message type='1' lock='true'><![CDATA[".md5($_POST["password"])." == ".$results[0]["password"]."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>