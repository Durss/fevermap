<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	2 - POST var missing
	3 - Not logged
	102 - token has expired
	103 - user locked

	*/

	$res = 0;
	if (isset($_POST["x"], $_POST["y"])) {
		//Get old area
		try {
			$sql = "SELECT x, y FROM feverUsers WHERE uid=".$_SESSION['uid'];
			$results = $Mysql->TabResSQL($sql);
		} catch (Erreur $e) {
			$res = 1;
		}
		
		if($res == 0) {
			//Update user
			try {
				$sql = "UPDATE feverUsers SET x=".mysql_real_escape_string($_POST["x"]).", y=".mysql_real_escape_string($_POST["y"])." WHERE uid=".$_SESSION['uid'];
				$Mysql->ExecuteSQL($sql);
			} catch (Erreur $e) {
				$res = 1;
			}
		}
		
		if($res == 0) {
			//Update new area
			try {
				$sql = "UPDATE feverAreas SET people=people+1 WHERE x=".mysql_real_escape_string($_POST["x"])." AND y=".mysql_real_escape_string($_POST["y"])." AND `world`=".intval($_POST['world']);
				$Mysql->ExecuteSQL($sql);
			} catch (Erreur $e) {
				$res = 1;
			}
		}
		
		if($res == 0) {
			//Update old area
			try {
				$sql = "UPDATE feverAreas SET people=people-1 WHERE x=".$results[0]['x']." AND y=".$results[0]['y']." AND `world`=".intval($_POST['world']);
				$Mysql->ExecuteSQL($sql);
			} catch (Erreur $e) {
				$res = 1;
			}
		}
	}else{
		$res = 2;
	}
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$res."</result>\r\n";
	//$result .= "\t<message type='1' lock='true'><![CDATA[".md5($_POST["password"])." == ".$results[0]["password"]."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>