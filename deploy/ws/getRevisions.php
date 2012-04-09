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
	103 - user locked

	*/

	$res = 0;
	$items = "";
	
	if ((isset($_POST["x"], $_POST["y"], $_POST["world"]) || isset($_POST["offset"], $_POST["total"]))) {
		try {
			if (isset($_POST["offset"])) {
				$sql = "SELECT * FROM feverUsersActions WHERE a_data!='' AND world=".mysql_real_escape_string($_POST["world"])." ORDER BY date DESC LIMIT ".$_POST["offset"].",".$_POST["total"];
			}else {
				$sql = "SELECT * FROM feverUsersActions WHERE x=".mysql_real_escape_string($_POST["x"])." AND y=".mysql_real_escape_string($_POST["y"])." AND world=".mysql_real_escape_string($_POST["world"])." ORDER BY date DESC";
			}
			$results = $Mysql->TabResSQL($sql);
		} catch (Erreur $e) {
			$res = 1;
		}
		
		if($res == 0) {
			$items = "\t<items>\r\n";
			for ($i = 0; $i < count($results); ++$i) {
				try {
					$sqlPseudo = "SELECT pseudo, locked FROM feverUsers WHERE uid='".$results[$i]["uid"]."'";
					$resultsPseudo = $Mysql->TabResSQL($sqlPseudo);
				} catch (Erreur $e) { $res = 1; break; }
				
				$items .= "\t\t<item uid='".$results[$i]["uid"]."' pseudo='".$resultsPseudo[0]["pseudo"]."' lock='".$resultsPseudo[0]["locked"]."' d='".$results[$i]["a_directions"]."' i='".$results[$i]["a_items"]."' e='".$results[$i]["a_enemies"]."' date='".$results[$i]["date"]."' matrix='".$results[$i]["a_data"]."' matrixBefore='".$results[$i]["b_data"]."' x='".$results[$i]["x"]."' y='".$results[$i]["y"]."' isNew='".$results[$i]["new"]."' />\r\n";
			}
			$items .= "\t</items>\r\n";
			
			
			if($res == 0) {
				try {
					$sql = "SELECT COUNT(id) as `total` FROM feverUsersActions WHERE a_data!='' AND world=".mysql_real_escape_string($_POST["world"]);
					$resultCount = $Mysql->TabResSQL($sql);
				} catch (Erreur $e) {
					$res = 1;
				}
				
				$offset = isset($_POST["offset"])? intval($_POST["offset"]) : 0;
				$total = isset($_POST["total"])? intval($_POST["total"]) : 0;
				$prev = (isset($_POST["offset"]) && $offset > 0)? 'true' : 'false';
				$next = ($offset + $total >= intval($resultCount[0]["total"]))? 'false' : 'true';
			}
		}
		
	}else {
		$res = 2;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result offset='".$offset."' total='".$total."' prev='".$prev."' next='".$next."' track='".(isset($_POST["offset"])? 'true' : 'false')."'>".$res."</result>\r\n";
	$result .= $items;
	//$result .= "\t<message type='1' lock='true'><![CDATA[".$sqlPseudo."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>