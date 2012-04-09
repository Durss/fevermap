<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	2 - Request params missing

	*/

	$resultCode = 0;
	//Get the user's world
	try {
		$sqlUser = "SELECT world FROM feverUsers WHERE uid=".$_SESSION["uid"];
		$results = $Mysql->TabResSQL($sqlUser);
		$world = $results[0]["world"];
	} catch (Erreur $e) {
		$resultCode = 1;
	}
	
	if($resultCode == 0) {
		try {
			$data = trim(file_get_contents('php://input'));
			$json = @json_decode($data);
			$validityCheck = $json != null && $json !== false;//json_last_error() === JSON_ERROR_NONE;
			
			if($validityCheck) {
				$sql = "UPDATE feverUsers SET data".intval($world)."=\"".mysql_real_escape_string($data)."\" WHERE uid=".$_SESSION["uid"];
				$Mysql->ExecuteSQL($sql);
			}else {
				$resultCode = 1;
			}
		} catch (Erreur $e) {
			$resultCode = 1;
		}
	}
	
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$resultCode."</result>\r\n";
	//$result .= "\t<r>".$validityCheck."</r>\r\n";
	//$result .= "\t<message type='2' lock='true'><![CDATA[".((json_decode(substr($data, 0, 200)) === false)? "0" : "1")."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;
	$Mysql->close();
?>