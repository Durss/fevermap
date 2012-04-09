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
	if (isset($_POST["offset"], $_POST["length"])) {
		try {
			$sql = "SELECT * FROM feverMessages ORDER BY date DESC LIMIT ".mysql_real_escape_string($_POST["offset"]).",".mysql_real_escape_string($_POST["length"]);
			$results = $Mysql->TabResSQL($sql);
		} catch (Erreur $e) {
			$res = 1;
		}
		
		$items = "\t<items>\r\n";
		for ($i = 0; $i < count($results); ++$i) {
			try {
				$sqlPseudo = "SELECT pseudo, locked FROM feverUsers WHERE uid='".$results[$i]["uid"]."'";
				$resultsPseudo = $Mysql->TabResSQL($sqlPseudo);
			} catch (Erreur $e) { $res = 1; break; }
			
			$items .= "\t\t<item id='".$results[$i]["id"]."' uid='".$results[$i]["uid"]."' pseudo='".$resultsPseudo[0]["pseudo"]."' lock='".$resultsPseudo[0]["locked"]."' date='".$results[$i]["date"]."' love='".$results[$i]["love"]."' reports='".(($results[$i]["uid"] == '89')? 0 : $results[$i]["reports"])."' reporters='".$results[$i]["reporters"]."'><![CDATA[".str_replace("\r\n", "\r", $results[$i]["message"])."]]></item>\r\n";
		}
		$items .= "\t</items>\r\n";
		
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