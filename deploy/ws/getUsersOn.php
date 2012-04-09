<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	2 - POST var missing
	102 - token has expired

	*/

	$res = 0;
	$items = "";
	$results = array();
	if (isset($_POST["x"], $_POST["y"], $_POST["world"]) || isset($_POST["pseudo"])) {
		try {
			if (isset($_POST["pseudo"])) {
				$sql = "SELECT * FROM feverUsers WHERE pseudo LIKE '%".mysql_real_escape_string($_POST["pseudo"])."%' OR uid='".mysql_real_escape_string($_POST["pseudo"])."' AND world=".intval($_POST["world"]);
			}else{
				$sql = "SELECT * FROM feverUsers WHERE x=".mysql_real_escape_string($_POST["x"])." AND y=".mysql_real_escape_string($_POST["y"])." AND world=".intval($_POST["world"]);
			}
			$results = $Mysql->TabResSQL($sql);
		} catch (Erreur $e) {
			$res = 1;
		}
		
		$items = "\t<users>\r\n";
		for ($i = 0; $i < count($results); ++$i) {
			$items .= "\t\t<user id='".$results[$i]["uid"]."' locked='".$results[$i]["locked"]."' x='".$results[$i]["x"]."' y='".$results[$i]["y"]."'><![CDATA[".$results[$i]["pseudo"]."]]></user>\r\n";
		}
		$items .= "\t</users>\r\n";
		
	}else {
		$res = 2;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$res."</result>\r\n";
	$result .= $items;
	//$result .= "\t<message type='1' lock='true'><![CDATA[".$sqlPseudo."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>