<?php
	
	require_once('connect.php');
	
	$countMine = 0;
	$total = 0;
	
	$sql = 'SELECT * FROM feverAreas';
	$results = $Mysql->TabResSQL($sql);
	$total = count($results);
	
	for($i=0; $i < $total; $i++) {
		$sql2 = 'SELECT * FROM feverUsersActions WHERE x='.$results[$i]["x"].' AND y='.$results[$i]["y"];
		$results2 = $Mysql->TabResSQL($sql);
		if($results2[0]["uid"] == $_GET["uid"]) $countMine ++;
	}
	
	echo "Tu as répertorié ".$countMine." îles sur un total de ".$total;
?>