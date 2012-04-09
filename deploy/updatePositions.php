<?php
	require_once('connect.php');
	
	
	if(!isset($_GET["start"])) {
		$sql2 = "UPDATE feverAreas SET people=0";
		$Mysql->ExecuteSQL($sql2);
	}
	
	$sqlCount = "SELECT COUNT(uid) as total FROM feverUsers";
	$results = $Mysql->TabResSQL($sqlCount);
	$total = $results[0]["total"];
	
	$step = 200;
	$start = isset($_GET["start"])? $_GET["start"] : 0;
	
	if ($total > $start + $step) {
		header("Refresh: .5; url=?start=".($start+$step));
	}
?>
<html>
	<head>
		<title>DataBase updater</title>
		<link rel="shortcut icon" href="./favicon.ico" />
	</head>
	<body>
<?php
	if($total > $start + $step) {
		echo "<a href='?start=".($start+$step)."'>".($start+$step)." à ".($start+$step+$step)."/".$total." -&gt;</a><br />";
	}else {
		echo "FINI!<br />";
	}
	
	$sql = "SELECT * FROM feverUsers LIMIT ".$start.",".$step;
	$results = $Mysql->TabResSQL($sql);
	
	for($i = 0; $i < count($results); $i++) {
		$sql2 = "UPDATE feverAreas SET people=people+1 WHERE x=".$results[$i]['x']." AND y=".$results[$i]['y']." AND world=".$results[$i]['world'];
		$Mysql->ExecuteSQL($sql2);
		echo "Update ".$results[$i]['x'].",".$results[$i]['y']."<br />";
	}
?>
	</body>
</html>