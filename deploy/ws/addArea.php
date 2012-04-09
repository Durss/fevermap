<?php
	require_once("../session.php"); 

	header("Content-type: text/xml"); 

	require_once('includes.php');

	/*
	Return codes signification :

	0 - success.
	1 - SQL add error
	2 - SQL update error
	3 - wrong parameter count
	4 - tracking error
	5 - updating adjacent area error
	100 - XML bad formated
	101 - page not found
	103 - user locked
		
	Binary order :	TLBR
					1111
	*/
	$resultCode = 0;
		
	function toDigits($nbr, $tot) {
		$str = $nbr;
		while (strlen($str) < $tot) $str = "0" . $str;
		return $str;
	}
	
	if(isset($_POST["x0"], $_POST["y0"], $_POST["d0"], $_POST["i0"], $_POST["e0"], $_POST["world"]) && !$user_locked) {
		$i = 0;
		while(isset($_POST["x".$i])) {
			//Check if a similar entry does not exists
			try {
				$sql = 'SELECT * FROM feverAreas WHERE x='.mysql_real_escape_string($_POST["x".$i]).' AND y='.mysql_real_escape_string($_POST["y".$i]).' AND world='.intval($_POST["world"]);
				$results = $Mysql->TabResSQL($sql);
			} catch (Erreur $e) {
				$resultCode = 1;
			}
			
			//If there is already an entry with the same coordinates, update it
			if (count($results) > 0) {
			
			/**********
			 * UPDATE *
			 **********/
			
				//Track modifications (only if something has changed)s
				if (($results[0]["items"] != $_POST["i".$i]
					|| $results[0]["directions"] != $_POST["d".$i]
					|| $results[0]["enemies"] != $_POST["e".$i]
					|| $results[0]["data"] != $_POST["data".$i]
					)&& $results[0]["data"] == intval($_POST["world"])) {
					$sql = 'INSERT INTO feverUsersActions
					(`uid`, `date`, `x`, `y`, `b_items`, `b_directions`, `b_enemies`, `b_data`, `a_items`, `a_directions`, `a_enemies`, `a_data`, `world`)
					VALUES (
					"'.$_SESSION["uid"].'",
					'.time().',
					'.mysql_real_escape_string($_POST["x".$i]).',
					'.mysql_real_escape_string($_POST["y".$i]).',
					"'.$results[0]["items"].'",
					"'.$results[0]["directions"].'",
					"'.$results[0]["enemies"].'",
					"'.mysql_real_escape_string($results[0]["data"]).'",
					"'.mysql_real_escape_string($_POST["i".$i]).'",
					"'.mysql_real_escape_string($_POST["d".$i]).'",
					"'.mysql_real_escape_string($_POST["e".$i]).'",
					"'.mysql_real_escape_string($_POST["data".$i]).'",
					"'.intval($_POST["world"]).'"
					)';
					try {
						$Mysql->ExecuteSQL($sql);
					} catch (Erreur $e) {
						$resultCode = 4;
						$sqlError = $sql."\n".$e;
						$handle = fopen("debug.txt", "w");
						fwrite($handle, $sqlError);
						break;
					}
				}
				
				//Save modifications
				if($resultCode == 0) {
					$sql = 'UPDATE feverAreas SET directions="'.mysql_real_escape_string($_POST["d".$i]).'", items="'.mysql_real_escape_string($_POST["i".$i]).'", enemies="'.mysql_real_escape_string($_POST["e".$i]).'", data="'.mysql_real_escape_string($_POST["data".$i]).'" WHERE x='.mysql_real_escape_string($_POST["x".$i]).' AND y='.mysql_real_escape_string($_POST["y".$i]).' AND world='.intval($_POST["world"]);
					try {
						$Mysql->ExecuteSQL($sql);
					} catch (Erreur $e) {
						$resultCode = 2;
						break;
					}
				}
				
			} else {
			
			/*******
			 * ADD *
			 *******/
			
				//Track modifications
				$sql = 'INSERT INTO feverUsersActions
				(`uid`, `date`, `x`, `y`, `new`, `b_items`, `b_directions`, `b_enemies`, `b_data`, `a_items`, `a_directions`, `a_enemies`, `a_data`, `world`)
				VALUES (
				"'.$_SESSION["uid"].'",
				'.time().',
				'.mysql_real_escape_string($_POST["x".$i]).',
				'.mysql_real_escape_string($_POST["y".$i]).',
				1,
				"",
				"0000",
				"0",
				"",
				"'.mysql_real_escape_string($_POST["i".$i]).'",
				"'.mysql_real_escape_string($_POST["d".$i]).'",
				"'.mysql_real_escape_string($_POST["e".$i]).'",
				"'.mysql_real_escape_string($_POST["data".$i]).'",
				"'.intval($_POST["world"]).'"
				)';
				try {
					$Mysql->ExecuteSQL($sql);
				} catch (Erreur $e) {
					$resultCode = 4;
					$sqlError = $sql."\n".$e;
					break;
				}
				
				//Save modifications
				if($resultCode == 0) {
					$sql = 'INSERT INTO feverAreas (`x`, `y`, `directions`, `items`, `enemies`, `data`, `world`) VALUES ('.mysql_real_escape_string($_POST["x".$i]).', '.mysql_real_escape_string($_POST["y".$i]).', "'.mysql_real_escape_string($_POST["d".$i]).'", "'.mysql_real_escape_string($_POST["i".$i]).'", "'.mysql_real_escape_string($_POST["e".$i]).'", "'.mysql_real_escape_string($_POST["data".$i]).'", "'.intval($_POST["world"]).'")';
					try {
						$Mysql->ExecuteSQL($sql);
					} catch (Erreur $e) {
						$resultCode = 1;
						$sqlError = $sql."\n".$e;
						break;
					}
				}
			}
			
			
			//Update adjacent areas
			//8, 4, 2, 1
			if ($resultCode == 0) {
				$directions = $_POST["d".$i];
				
				//Top
				$sql = "SELECT * FROM feverAreas WHERE `x`=".mysql_real_escape_string($_POST["x".$i])." AND `y`=".mysql_real_escape_string($_POST["y".$i]-1)." AND `world`=".intval($_POST["world"]);
				try { $results = $Mysql->TabResSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				if (count($results) == 1) {
					$dirs = str_replace("\0", "", $results[0]["directions"]);
					$dirs[2] = $directions[0];
					$sql = "UPDATE feverAreas SET directions='".toDigits($dirs, 4)."' WHERE `x`=".mysql_real_escape_string($_POST["x".$i])." AND `y`=".mysql_real_escape_string($_POST["y".$i]-1)." AND `world`=".intval($_POST["world"]);
					try { $Mysql->ExecuteSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				}
				
				//left
				$sql = "SELECT * FROM feverAreas WHERE `x`=".mysql_real_escape_string($_POST["x".$i]-1)." AND `y`=".mysql_real_escape_string($_POST["y".$i])." AND `world`=".intval($_POST["world"]);
				try { $results = $Mysql->TabResSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				if (count($results) == 1) {
					$dirs = str_replace("\0", "", $results[0]["directions"]);
					$dirs[3] = $directions[1];
					$sql = "UPDATE feverAreas SET directions='".toDigits($dirs, 4)."' WHERE `x`=".mysql_real_escape_string($_POST["x".$i]-1)." AND `y`=".mysql_real_escape_string($_POST["y".$i])." AND `world`=".intval($_POST["world"]);
					try { $Mysql->ExecuteSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				}
				
				//Bottom
				$sql = "SELECT * FROM feverAreas WHERE `x`=".mysql_real_escape_string($_POST["x".$i])." AND `y`=".mysql_real_escape_string($_POST["y".$i]+1)." AND `world`=".intval($_POST["world"]);
				try { $results = $Mysql->TabResSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				if (count($results) == 1) {
					$dirs = str_replace("\0", "", $results[0]["directions"]);
					$dirs[0] = $directions[2];
					$sql = "UPDATE feverAreas SET directions='".toDigits($dirs, 4)."' WHERE `x`=".mysql_real_escape_string($_POST["x".$i])." AND `y`=".mysql_real_escape_string($_POST["y".$i]+1)." AND `world`=".intval($_POST["world"]);
					try { $Mysql->ExecuteSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				}
				
				//Right
				$sql = "SELECT * FROM feverAreas WHERE `x`=".mysql_real_escape_string($_POST["x".$i]+1)." AND `y`=".mysql_real_escape_string($_POST["y".$i])." AND `world`=".intval($_POST["world"]);
				try { $results = $Mysql->TabResSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				if (count($results) == 1) { 
					$dirs = str_replace("\0", "", $results[0]["directions"]);
					$dirs[1] = $directions[3];
					$sql = "UPDATE feverAreas SET directions='".toDigits($dirs, 4)."' WHERE `x`=".mysql_real_escape_string($_POST["x".$i]+1)." AND `y`=".mysql_real_escape_string($_POST["y".$i])." AND `world`=".intval($_POST["world"]);
					try { $Mysql->ExecuteSQL($sql); } catch (Erreur $e) { $resultCode = 5; break; }
				}
			}
			
			$i ++;
		}
	}else if($user_locked) {
		$resultCode = 402;
	}else{
		$resultCode = 3;
	}

	$result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
	$result .= "<root>\r\n";
	$result .= "\t<result>".$resultCode."</result>\r\n";
	//$result .= "\t<message type='2' lock='false'><![CDATA[".$sqlError."]]></message>\r\n";
	$result .= "</root>\r\n";
	echo $result;

	$Mysql->close();
?>