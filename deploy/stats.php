<?php
	require_once('connect.php');
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverAreas` WHERE `world`=0 ';
	$results = $Mysql->TabResSQL($sql);
	$submitted0 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverAreas` WHERE `cleaned`=1 && `world`=0';
	$results = $Mysql->TabResSQL($sql);
	$cleaned0 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverUsersActions` WHERE `world`=0';
	$results = $Mysql->TabResSQL($sql);
	$revisions0 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverUsers` WHERE `world`=0';
	$results = $Mysql->TabResSQL($sql);
	$users0 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(id) as `total`, `uid` FROM `feverUsersActions` WHERE `world`=0 GROUP BY `uid` ORDER BY `total` DESC LIMIT 0, 10';
	$results = $Mysql->TabResSQL($sql);
	$tot0 = count($results);
	$adminsRank0 = "<table width='100%'>";
	$adminsRank0 .= "	<tr bgcolor='#291612'><td>Pseudo</td><td>Révisions</td></tr>";
	for($i=0; $i < $tot0; $i++) {
		$sql2 = 'SELECT `pseudo` FROM feverUsers WHERE uid='.$results[$i]["uid"];
		$results2 = $Mysql->TabResSQL($sql2);
		$adminsRank0 .= "<tr>";
		$adminsRank0 .= "<td><a href='http://muxxu.com/u/".$results2[0]['pseudo']."' target='_blank'>".$results2[0]['pseudo']."</a></td><td>".$results[$i]["total"]."</td>";
		$adminsRank0 .= "</tr>";
	}
	$adminsRank0 .= "</table>";
	
	
	
	
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverAreas` WHERE `world`=1 ';
	$results = $Mysql->TabResSQL($sql);
	$submitted1 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverAreas` WHERE `cleaned`=1 && `world`=1';
	$results = $Mysql->TabResSQL($sql);
	$cleaned1 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverUsersActions` WHERE `world`=1';
	$results = $Mysql->TabResSQL($sql);
	$revisions1 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(*) as `total` FROM `feverUsers` WHERE `world`=1';
	$results = $Mysql->TabResSQL($sql);
	$users1 = $results[0]["total"];
	
	$sql = 'SELECT COUNT(id) as `total`, `uid` FROM `feverUsersActions` WHERE `world`=1 GROUP BY `uid` ORDER BY `total` DESC LIMIT 0, 10';
	$results = $Mysql->TabResSQL($sql);
	$tot1 = count($results);
	$adminsRank1 = "<table width='100%'>";
	$adminsRank1 .= "	<tr bgcolor='#291612'><td>Pseudo</td><td>Révisions</td></tr>";
	for($i=0; $i < $tot1; $i++) {
		$sql2 = 'SELECT `pseudo` FROM feverUsers WHERE uid='.$results[$i]["uid"];
		$results2 = $Mysql->TabResSQL($sql2);
		$adminsRank1 .= "<tr>";
		$adminsRank1 .= "<td><a href='http://muxxu.com/u/".$results2[0]['pseudo']."' target='_blank'>".$results2[0]['pseudo']."</a></td><td>".$results[$i]["total"]."</td>";
		$adminsRank1 .= "</tr>";
	}
	$adminsRank1 .= "</table>";
	
	
	
	
	
	$sql = 'SELECT `pseudo` FROM `feverUsers` WHERE `rights`=1';
	$results = $Mysql->TabResSQL($sql);
	$admins = "<table width='100%'>";
	$admins .= "	<tr bgcolor='#291612'><td colspan='2'>Pseudo</td></tr>";
	$tot = count($results);
	for ($i = 0; $i < $tot; $i += 2) {
		$admins .= "<tr>";
		$admins .= "<td><a href='http://muxxu.com/u/".$results[$i]['pseudo']."' target='_blank'>".$results[$i]['pseudo']."</a></td>";
		if($i+1<$tot-1) {
			$admins .= "<td><a href='http://muxxu.com/u/".$results[$i + 1]['pseudo']."' target='_blank'>".$results[$i + 1]['pseudo']."</a></td>";
		}
		$admins .= "</tr>";
	}
	$admins .= "</table>";
	

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">
	<head>
		<title>FeverMap</title>
		<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
		<link rel="shortcut icon" href="./favicon_new.ico" />
		<style type="text/css">
		html, body {
			overflow:auto;
			height:100%;
			margin:0;
			padding:0;
			font-family: Trebuchet MS,Arial,sans-serif;
		}
		body {
			background: url("images/background") repeat scroll 0 190px transparent;
			font: 86 % Arial, "Helvetica Neue", sans - serif;
			color:#ffffff;
			margin: 0;                
		}
		b {
			color:#FF8000;
		}
		a {
			color:#f0f0f0;
			text-decoration:underline;
		}
		a:hover {
			color:#F42D2D;
		}
		#content {
			height: 100%;
		}
		#title {
			background-color: black;
			height: 26px;
			width:400px;
		}
		#section {
			border-width: 1px;
			border-color: #000000;
			border-style: solid;
			background-color: #412720;
			text-align:left;
			padding: 10px;
			overflow: hidden;
			width: 378px;
		}
		</style>
		
		<script type="text/javascript" src="js/ZeroClipboard.js"></script>
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript">

		  var _gaq = _gaq || [];
		  _gaq.push(['_setAccount', 'UA-21417708-1']);
		  _gaq.push(['_trackPageview']);

		  (function() {
			var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
			ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
			var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		  })();

		</script>
    </head>
    <body>
		<center>
			<br />
			<div id="title">Statistiques Gonkrogme</div>
			<div id="section"><b>Îles repertoriées :</b> <?php echo $submitted0." (".floor(($submitted0)/100)."%)"; ?></div>
			<div id="section"><b>Îles Nettoyées :</b> <?php echo$cleaned0." (".floor(($cleaned0)/100)."%)"; ?></div>
			<div id="section"><b>Révisions effectuées :</b> <?php echo $revisions0; ?></div>
			<div id="section"><b>Utilisateurs :</b> <?php echo $users0; ?></div>
			<div id="section"><b>Top admins :</b> <?php echo $adminsRank0; ?></div>
			<br />
			<div id="title">Statistiques Sultura</div>
			<div id="section"><b>Îles repertoriées :</b> <?php echo $submitted1." (".floor(($submitted1)/100)."%)"; ?></div>
			<div id="section"><b>Îles Nettoyées :</b> <?php echo $cleaned1." (".floor(($cleaned1)/100)."%)"; ?></div>
			<div id="section"><b>Révisions effectuées :</b> <?php echo $revisions1; ?></div>
			<div id="section"><b>Utilisateurs :</b> <?php echo $users1; ?></div>
			<div id="section"><b>Top admins :</b> <?php echo $adminsRank1; ?></div>
			<br />
			<div id="title">Admins</div>
			<div id="section"><b> <?php echo $admins; ?></b></div>
		</center>
	</body>
</html>