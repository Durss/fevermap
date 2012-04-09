<?php

	$data_version = 15;
	$need_update = false;
	$user_locked = false;
	$user_rights = 0;//0=>none ; 1=>admin
	$user_logged = isset($_SESSION["name"]);
	/*
	if (!isset($_POST["token"]) || ($_POST["token"] - time() > 15000 || $_POST["token"] < time())) {
		$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
		$result .= "<root>\r\n";
		$result .= "\t<result>401</result>\r\n";
		$result .= "\t<token>".$_POST["token"]."</token>\r\n";
		$result .= "\t<time>".time()."</time>\r\n";
		$result .= "\t<diff>".($_POST["token"] - time())."</diff>\r\n";
		$result .= "</root>\r\n";
		echo $result;
		die;
	}*/
	
	if($user_logged) {
		$sqlChck = "SELECT locked, rights FROM feverUsers WHERE uid='".$_SESSION["uid"]."'";
		$resultsChck = $Mysql->TabResSQL($sqlChck);
		if ($resultsChck[0]["locked"] == 1) {
			$user_locked = true;
		}
		$user_rights = $resultsChck[0]["rights"];
	}else if(!isset($lockOnLogin) || $lockOnLogin !== false) {
		$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
		$result .= "<root>\r\n";
		$result .= "\t<result>400</result>\r\n";
		$result .= "</root>\r\n";
		echo $result;
		die;
	}

	if(isset($_POST["version"]) && $_POST["version"] < $data_version) {
		$need_update = true;
		$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
		$result .= "<root>\r\n";
		$result .= "\t<result>200</result>\r\n";
		$result .= "</root>\r\n";
		echo $result;
		die;
	}

?>