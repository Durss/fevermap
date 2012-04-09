<?php
	
	require_once('connect.php');
	if(!isset($_GET["uid"])) die("poil");
	
	$page = 200;
	$countMine = isset($_GET["total"])? $_GET["total"] : 0;
	$total = 0;
	$offset = isset($_GET["offset"])? $_GET["offset"] : 0;
	
	$sql = 'SELECT * FROM feverAreas';
	$results = $Mysql->TabResSQL($sql);
	$total = count($results);
	
	$sql = 'SELECT * FROM feverAreas LIMIT '.$offset.','.$page;
	$results = $Mysql->TabResSQL($sql);
	$tot = count($results);
	
	for($i=0; $i < $tot; $i++) {
		$sql2 = 'SELECT * FROM feverUsersActions WHERE x='.$results[$i]["x"].' AND y='.$results[$i]["y"].' ORDER BY id ASC LIMIT 0,1';
		$results2 = $Mysql->TabResSQL($sql2);
		if($results2[0]["uid"] == $_GET["uid"]) $countMine ++;
	}
	
	if($offset + $page < $total) {
		header("Refresh: 1; url=?uid=".$_GET['uid']."&offset=".($offset + $page)."&total=".$countMine);
		echo "redirecting...";
	}else{
		echo "Tu as répertorié ".$countMine." îles sur un total de ".$total."<br />";
	}
?>