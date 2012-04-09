<?php
	session_start();
	
	$str = "";
	$world = isset($_GET["w"])? intval($_GET["w"]) : 0;
	
	if (!isset($_SESSION["name"])) {
		$str =  "Houste sale bete!";
	}else{
		require_once('connect.php');
		
		if(!isset($_GET["start"])) {
			$sql = "SELECT data".$world." as `data`, pseudo FROM feverUsers WHERE rights>0 AND world=".$world;
			$results = $Mysql->TabResSQL($sql);
			
			$islands = array();
			for($i = 0; $i < count($results); $i++) {
				$data = json_decode($results[$i]["data"], true);
				if(!isset($data["cleaned"]) || count($data["cleaned"]) == 0) continue;
				foreach($data["cleaned"] as $key => $value) {
					list($x,$y) = explode(":", $key);
					$islands[$x."_".$y] = array($x, $y);
				}
				/*
				echo "<br /><br />".$results[$i]["pseudo"]."<br />";
				foreach($islands as $key => $value) {
					echo $value[0]."_".$value[1]."<br />";
				}
				*/
			}
			
			$sql2 = "UPDATE feverAreas SET cleaned=0 WHERE world=".$world;
			$Mysql->ExecuteSQL($sql2);
			
			$_GET["start"] = 0;
			$_SESSION["islands"] = $islands;
		}else {
			$islands = $_SESSION["islands"];
		}
		
		
		$length = 150;
		$start = intval($_GET["start"]);
		$increment = 0;
		$total = count($islands);
		foreach($islands as $key => $value) {
			$increment ++;
			if ($increment < $start) continue;
			if ($increment >= $start + $length) {
				if(min($total, $increment + $length) <= $total) {
					header("Refresh: .5; url=?start=".($start+$length)."&w=".$world);
					$str =  "Please wait... Updating results ".$increment."->".min($total, $increment+$length)." / ".$total;
				}
				break;
			}
			try {
				$sql2 = "UPDATE feverAreas SET cleaned=1 WHERE x=".$value[0]." AND y=".$value[1]." AND world=".$world;
				$Mysql->ExecuteSQL($sql2);
			}catch (Erreur $e) {
				$str = "<font color='#cc0000'>An error as occured :: ".$sql2."</font><br />";
				break;
			}
		}
		if($increment == $total) {
			$str =  "Ayééééééééé a tout finiiii!";
		}
	}
?>
<html>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<head>
		<title>FeverMap :: DataBase updater</title>
		<link rel="shortcut icon" href="./favicon.ico" />
	</head>
	<body>
<?php
	echo $str;
?>
	</body>
</html>