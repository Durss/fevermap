<?php
	require_once("../session.php"); 

	header("Content-type: text/xml");

	require_once('includes.php');


	/*
	Return codes signification :

	0 - success.
	1 - SQL error
	2 - POST var missing.
	100 - XML bad formated
	101 - page not found
	102 - token expired

	*/

	$px = 0;
	$py = 0;
	$flags = "";
	$items = "";
	$maxZones = 1000;
	$resultCode = 0;
	
	if ($resultCode == 0 && isset($_POST["getFlags"])) {
		try {
			$sql = "SELECT * FROM feverUsers WHERE uid=".$_SESSION["uid"];
			$results = $Mysql->TabResSQL($sql);
			//$world = $results[0]['world'];
			$data = $results[0]['data'.intval($_POST["world"])];
		} catch (Erreur $e) {
			$resultCode = 1;
		}
		$flags = "\t<data><![CDATA[".$data."]]></data>\r\n";
	}

	if (isset($_POST["xmin"], $_POST["xmax"], $_POST["ymin"], $_POST["ymax"], $_POST["world"]) || isset($_POST["pathfinderMode"])) {
		//Get the current world the user is registered on
		try {
			$sql = "SELECT * FROM `feverUsers` WHERE `uid`=".$_SESSION["uid"];
			$results = $Mysql->TabResSQL($sql);
			$world = $results[0]["world"];
		} catch (Erreur $e) {
			$resultCode = 1;
		}
		
		if ($resultCode == 0) {
			//If the user just changed from world
			if ($_POST["world"] != $world) {
				//Get the position related to the new world in the JSON data (dirty... but... fuck :D)
				$json = $results[0]["data".intval($_POST["world"])];
				if(strlen($json) > 0) {
					$data = json_decode($json, true);
					$px = $data["poustyPos"]["x"];
					$py = $data["poustyPos"]["y"];
				}
				
				//Remove us from the old world
				try {
					$sql = "UPDATE feverAreas SET people=people-1 WHERE x=".$results[0]['x']." AND y=".$results[0]['y']." AND `world`=".$world;
					$Mysql->ExecuteSQL($sql);
				} catch (Erreur $e) {
					$res = 1;
				}
				
				//Add us to the new world
				try {
					$sql = "UPDATE feverAreas SET people=people+1 WHERE x=".$px." AND y=".$py." AND `world`=".intval($_POST["world"]);
					$Mysql->ExecuteSQL($sql);
				} catch (Erreur $e) {
					$res = 1;
				}
				
				//Updates the user's world
				try {
					$sql = "UPDATE feverUsers SET world=".intval($_POST["world"]).", x=".$px.", y=".$py." WHERE uid=".$_SESSION["uid"];
					$Mysql->ExecuteSQL($sql);
				} catch (Erreur $e) {
					$resultCode = 1;
				}
			}
			
			if($resultCode == 0) {
				if(!isset($_POST["pathfinderMode"])) {
					if (abs($_POST["xmin"] - $_POST["xmax"]) > $maxZones) $_POST["xmax"] = $_POST["xmin"] + $maxZones;
					if (abs($_POST["ymin"] - $_POST["ymax"]) > $maxZones) $_POST["ymax"] = $_POST["ymin"] + $maxZones;
				
					try {
						$sqlCount = "SELECT COUNT(uid) as total FROM feverUsers WHERE x!=0 AND y!=0 AND world=".mysql_real_escape_string($_POST["world"]);
						$results = $Mysql->TabResSQL($sqlCount);
						$totalUsers = $results[0]["total"];
					} catch (Erreur $e) {
						$resultCode = 1;
					}
				
					if($resultCode == 0) {
						try {
							$sql = 'SELECT * FROM feverAreas WHERE x>='.mysql_real_escape_string($_POST["xmin"]).' AND x<='.mysql_real_escape_string($_POST["xmax"]).' AND y>='.mysql_real_escape_string($_POST["ymin"]).' AND y<='.mysql_real_escape_string($_POST["ymax"]).' AND world='.mysql_real_escape_string($_POST["world"]);
							$results = $Mysql->TabResSQL($sql);

							//$result .= "\t<sql><![CDATA[".$sql."]]></sql>\r\n";
							$resultCode = 0;
							$items = "\t<items>\r\n";
							for ($i = 0; $i < count($results); ++$i) {
								$items .= "\t\t<item x='".$results[$i]["x"]."' y='".$results[$i]["y"]."' d='".$results[$i]["directions"]."' i='".$results[$i]["items"]."' e='".$results[$i]["enemies"]."' p='".$results[$i]["people"]."' t='".$totalUsers."' data='".$results[$i]["data"]."' c='".$results[$i]["cleaned"]."' />\r\n";
							}
							$items .= "\t</items>\r\n";
						} catch (Erreur $e) {
							$resultCode = 1;
						}
					}
				}else {
					try {
						$sql = 'SELECT x, y, directions, items FROM feverAreas WHERE world='.mysql_real_escape_string($_POST["world"]);
						$results = $Mysql->TabResSQL($sql);

						//$result .= "\t<sql><![CDATA[".$sql."]]></sql>\r\n";
						$resultCode = 0;
						$items = "\t<pfMode />\r\n";
						$items .= "\t<items>\r\n";
						for ($i = 0; $i < count($results); ++$i) {
							$items .= "\t\t<item x='".$results[$i]["x"]."' y='".$results[$i]["y"]."' d='".$results[$i]["directions"]."' i='".$results[$i]["items"]."' />\r\n";
						}
						$items .= "\t</items>\r\n";
					} catch (Erreur $e) {
						$resultCode = 1;
						}
				}
			}
		}
	}else {
		$resultCode = 2;
	}

	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root px='".$px."' py='".$py."'>\r\n";
	$result .= "\t<result>".$resultCode."</result>\r\n";
	$result .= $items;
	$result .= $flags;
	//$result .= "\t<message type='1' lock='false'><![CDATA[".$_POST["xmin"]." :: ".$_POST["ymin"]." :: ".$_POST["xmax"]." :: ".$_POST["ymax"]."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;
	/*
	echo "\t<message type='1' lock='true'><![CDATA[".$resultCode;
	print_r($decrypt);
	echo "]]></message>\r\n";
	echo "</root>\r\n";
	*/
	//echo "<root>".RequestEncrypter::encrypt($result)."</root>";

	$Mysql->close();
?>