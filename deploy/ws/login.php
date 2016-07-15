<?php
	require_once("../session.php"); 
	
	header("Content-type: text/xml");
	
	$lockOnLogin = false;
	require_once('includes.php');

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	2 - POST var missing
	3 - Invalid logins
	4 - Unable to register user
	102 - token has expired
	200 - needs an update

	*/
	if(isset($_POST["logout"])) {
		session_destroy();
	}

	$res = 0;
	$rights = 0;
	$data = "";
	$world = 0;
	
	if (isset($_POST["pubkey"], $_POST["uid"])) {
		if(!$user_logged || $_SESSION["uid"] != $_POST["uid"] || $_SESSION["pubkey"] != $_POST["pubkey"]) {
			$url = "http://muxxu.com/app/xml?app=fevermap&xml=user&id=".$_POST['uid']."&key=".md5("d1268d376ba9e54593b4ca03c756f1a1" . $_POST["pubkey"]);
			$xml = @file_get_contents($url);
			preg_match('/name="(.*?)"/', $xml, $matches); //*? = quantificateur non gourmand
			
			if (strpos($xml, "<error>") === false && count($matches) > 1) {
				//$user_logged	= true;
				$_SESSION["uid"]	= $_POST["uid"];
				$_SESSION["name"]	= $matches[1];
				$_SESSION["pubkey"]	= $_POST["pubkey"];
			}else {
				session_destroy();
				$res = 3;
			}
		}
		
		if($res == 0) {
			$sql = "SELECT * FROM feverUsers WHERE uid=".mysql_real_escape_string($_POST["uid"]);
			try {
				$sqlRes = $Mysql->TabResSQL($sql);
			}catch (Erreur $e) {
				$res = 1;
			}
			if ($res == 0 && count($sqlRes) == 0) {
				$sql = "INSERT INTO feverUsers (`uid`, `pseudo`) VALUES (".mysql_real_escape_string($_POST["uid"]).", '".$_SESSION["name"]."')";
				try {
					$Mysql->ExecuteSQL($sql);
				}catch (Erreur $e) {
					$res = 1;
				}
				try {
					$sql = "UPDATE feverAreas SET people=people+1 WHERE x=0 AND y=0";
					$Mysql->ExecuteSQL($sql);
				} catch (Erreur $e) {
					$res = 1;
				}
			}else {
				$sql = "UPDATE feverUsers SET `pseudo`='".$_SESSION["name"]."' WHERE `uid`=".mysql_real_escape_string($_POST["uid"]);
				try {
					$Mysql->ExecuteSQL($sql);
				}catch (Erreur $e) {
					$res = 1;
				}
			}
			if ($res == 0) {
				$rights = $sqlRes[0]["rights"];
				$world = $sqlRes[0]["world"];
				if($rights == 1) $_SESSION["admin"] = true;
				else $_SESSION["admin"] = false;
			}
		}
			
	}else if(!isset($_POST["logout"])){
		$res = 2;
	}
	
	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$res."</result>\r\n";
	$result .= "\t<sessID>".session_id()."</sessID>\r\n";
	$result .= "\t<data>".RequestEncrypter::encrypt("<root><rights><![CDATA[".$rights."]]></rights><world>".$world."</world></root>")."</data>\r\n";
	if(isset($sqlRes) && $res==0) {
		$world = $sqlRes[0]["world"];
		$result .= "\t<json>".$sqlRes[0]["data".$world]."</json>\r\n";
	}
	/**
	@session_start();
	$_SESSION["uid"]	= $_POST["uid"];
	$_SESSION["name"]	= "durss";
	$_SESSION["pubkey"]	= $_POST["pubkey"];
	$result .= "\t<result>0</result>\r\n";
	//*/
	//$result .= "\t<message type='1' lock='true'><![CDATA[".(strpos($xml, "<error>") === false)."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>