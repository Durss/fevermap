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
	if (isset($_POST["id"]) && !$user_locked) {
		try {
			$sql = "SELECT uid, reporters FROM `feverMessages` WHERE id=".mysql_real_escape_string($_POST["id"]);
			$results = $Mysql->TabResSQL($sql);
		} catch (Erreur $e) {
			$resultCode = 1;
		}
		if($resultCode == 0 && strpos($results[0]["reporters"], $_SESSION["uid"]) === false && $results[0]["uid"] != 89) {
			try {
				$sql = "UPDATE `feverMessages` SET reports=reports+".(($_SESSION["uid"]=='89')? 5 : 1).", reporters=CONCAT(reporters,'".$_SESSION["uid"].",') WHERE id=".mysql_real_escape_string($_POST["id"]);
				$Mysql->ExecuteSQL($sql);
			} catch (Erreur $e) {
				$resultCode = 1;
			}
		}
	}else if($user_locked) {
		$resultCode = 402;
	}else{
		$resultCode = 2;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$resultCode."</result>\r\n";
	//$result .= "\t<message type='1' lock='true'><![CDATA[".$sql."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>