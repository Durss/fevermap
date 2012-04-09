<html>
	<head>
		<title>DataBase updater</title>
		<link rel="shortcut icon" href="./favicon.ico" />
	</head>
	<body>
<?php
	require_once('connect.php');

	
	
	
	//==================================================================================================================
	//===================================================== STEP 1 =====================================================
	//==================================================================================================================
	
	if(!isset($_GET["step"])) {
		$sql = 'ALTER TABLE `feverAreas` CHANGE `enemies` `enemies` VARCHAR( 255 ) NOT NULL ';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsers` CHANGE `userName` `pseudo` VARCHAR( 25 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsers` CHANGE `id` `uid` INT( 11 ) NOT NULL AUTO_INCREMENT;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsers` DROP `password`;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsers` ADD `data` TEXT NOT NULL;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsers` ADD `rights` TINYINT NOT NULL ;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsersActions` CHANGE `userId` `uid` INT( 11 ) NOT NULL;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsersActions` ADD `updated` BOOL NOT NULL;';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsersActions` ADD `new` BOOL NOT NULL AFTER `y`';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsersActions` CHANGE `b_enemies` `b_enemies` VARCHAR( 255 ) NOT NULL';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `feverUsersActions` CHANGE `a_enemies` `a_enemies` VARCHAR( 255 ) NOT NULL';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'CREATE TABLE `feverMessages` (`id` INT NOT NULL AUTO_INCREMENT ,`uid` INT NOT NULL ,`date` INT NOT NULL ,`message` TEXT NOT NULL ,PRIMARY KEY ( `id` ) ,UNIQUE (`id`))';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">FeverMessages creation success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">FeverMessages creation faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'ALTER TABLE `fevermessages` ADD `love` TINYINT NOT NULL';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Structure update success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Structure update faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$ids = array("Durss"=>89,
					"Musaran"=>589,
					"Basile8"=>430,
					"Brisespoir"=>665,
					"Louleke"=>130,
					"Colapsydo"=>12832,
					"Xuisis"=>112,
					"Sergip"=>859,
					"Moulins"=>543,
					"Nuts3535"=>248175,
					"donfeuxvideo"=>3136,
					"fred93"=>13314,
					"Turok"=>46985,
					"Gluttony"=>6407,
					"Dentyleo"=>12583,
					"N0ktis"=>1536,
					"Henai"=>816,
					"Naity"=>18576,
					"Maloups"=>14745,
					"Vasari"=>7819,
					"Florimel"=>3796,
					"Thorg"=>77836,
					"Leg0wlas"=>3482,
					"Peacku"=>16108,
					"Tubasa"=>274,
					"Declan"=>207,
					"Cabra"=>4168,
					"Etti"=>8661,
					"Halfman"=>1247,
					"Viny52"=>10456,
					"Aballister"=>18728,
					"juju813"=>23397,
					"saxtenor"=>3208,
					"Labrys"=>123523,
					"Lucien312"=>553895,
					"Sconz"=>697,
					"Rimoach"=>134021,
					"skeletax"=>24072,
					"Fleurnim"=>451936,
					"Oshyso"=>51474,
					"Francois38"=>258383,
					"YpSeN"=>222922,
					"tikoc"=>15609,
					"yoxio"=>450120,
					"NeAr9"=>437479,
					"JoNn"=>2572,
					"chris932007"=>36,
					"Nawick"=>5228,
					"Awashi"=>2751,
					"theshield"=>10652,
					"Kinguillaume"=>94859,
					"Hyoga"=>58266,
					"aerynsun"=>13936,
					"Duckynator"=>233,
					"Slimfr01"=>671,
					"Elguigo"=>313,
					"Elios13"=>61344,
					"Dashi"=>875,
					"Arma275"=>408,
					"vapordinateu"=>13350);
		$sql = "SELECT * FROM feverUsers";
		$results = $Mysql->TabResSQL($sql);
		
		for ($i = 0; $i < count($results); $i++) {
			$pseudo = $results[$i]["pseudo"];
			$sql1 = 'UPDATE feverUsersActions SET updated=1, uid='.$ids[$pseudo].' WHERE updated=0 AND uid='.$results[$i]["uid"].' ';
			try {
				$Mysql->ExecuteSQL($sql1);
				echo '<font color="#00cc00">Actions Update OK pour '.$pseudo.'</font><br />';
			} catch (Erreur $e) {
				echo '<font color="#cc0000">Actions Update KO pour '.$pseudo.'</font><br />';
			}
			
			$sql2 = 'UPDATE feverUsers SET uid='.$ids[$pseudo].', rights=1 WHERE pseudo="'.$pseudo.'"';
			try {
				$Mysql->ExecuteSQL($sql2);
				echo '<font color="#00cc00">UID Update OK pour '.$pseudo.'</font><br />';
			} catch (Erreur $e) {
				echo '<font color="#cc0000">UID Update KO pour '.$pseudo.'</font><br />';
			}
		}
		
		$sql = 'ALTER TABLE `feverUsersActions` DROP `updated`;';
		try {
			$Mysql->ExecuteSQL($sql);
			echo '<font color="#00cc00">Structure update success!</font><br />';
		}catch (Erreur $e) {
			echo '<font color="#cc0000">Structure update faillure!<br />'.$e.'</font><br />';
		}
		
		$sql = 'UPDATE `feverUsers` SET `pseudo`="Arma" WHERE `uid`=408';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Pseudo update 1 success!</font><br />'; }catch (Erreur $e) { echo '<font color="#cc0000">Pseudo update 2 faillure!<br /><b>'.$e.'</b></font><br />'; }
		
		$sql = 'UPDATE `feverUsers` SET `pseudo`="Louleke77" WHERE `uid`=130';
		try { $Mysql->ExecuteSQL($sql); echo '<font color="#00cc00">Pseudo update 2 success!</font><br />'; } catch (Erreur $e) { echo '<font color="#cc0000">Pseudo update 2 faillure!<br /><b>'.$e.'</b></font><br />'; }
	
	}
	
	
	
	//==================================================================================================================
	//===================================================== STEP 2 =====================================================
	//==================================================================================================================
	
	if($_GET["step"] == "2") {
		$sql = "SELECT * FROM feverAreas";
		$results = $Mysql->TabResSQL($sql);
		
		for ($i = 0; $i < count($results); $i++) {
			$enemies = "";
			for ($j = 0; $j < $results[$i]["enemies"]; $j++) {
				$enemies .= "1,";
			}
			$enemies = substr($enemies, 0, strlen($enemies)-1);
			$sql1 = 'UPDATE feverAreas SET enemies="'.$enemies.'" WHERE id='.$results[$i]["id"];
			try {
				$Mysql->ExecuteSQL($sql1);
				echo '<font color="#00cc00">Areas Update OK en '.$results[$i]["x"].','.$results[$i]["y"].'</font><br />';
			} catch (Erreur $e) {
				echo '<font color="#cc0000">Areas Update KO en '.$results[$i]["x"].','.$results[$i]["y"].'</font><br />';
			}
		}
	}
	
	
	
	
	//==================================================================================================================
	//===================================================== STEP 3 =====================================================
	//==================================================================================================================
	
	if($_GET["step"] == "3") {
		$sql = "SELECT * FROM feverUsersActions";
		$results = $Mysql->TabResSQL($sql);
		
		for ($i = 0; $i < count($results); $i++) {
			$b_enemies = "";
			$a_enemies = "";
			for ($j = 0; $j < $results[$i]["b_enemies"]; $j++) {
				$b_enemies .= "1,";
			}
			for ($j = 0; $j < $results[$i]["a_enemies"]; $j++) {
				$a_enemies .= "1,";
			}
			$a_enemies = substr($a_enemies, 0, strlen($a_enemies)-1);
			$b_senemies = substr($b_enemies, 0, strlen($b_enemies)-1);
			$sql1 = 'UPDATE feverUsersActions SET b_enemies="'.$b_enemies.'", a_enemies="'.$a_enemies.'" WHERE id='.$results[$i]["id"];
			try {
				$Mysql->ExecuteSQL($sql1);
				echo '<font color="#00cc00">Areas Update OK en '.$results[$i]["x"].','.$results[$i]["y"].'</font><br />';
			} catch (Erreur $e) {
				echo '<font color="#cc0000">Areas Update KO en '.$results[$i]["x"].','.$results[$i]["y"].'</font><br />';
			}
		}
	}
	
	
	
	
	
	//==================================================================================================================
	//=================================================== STEP LINK ====================================================
	//==================================================================================================================
	
	if (!isset($_GET["step"])) {
		echo "<br /><a href='?step=2'>Step 2</a>";
	}else if ($_GET["step"] == "2") {
		echo "<br /><a href='?step=3'>Step 3</a>";
	}
?>
	</body>
</html>