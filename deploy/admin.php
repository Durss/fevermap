<?php
	session_start();
	require_once('connect.php');

	$accessGranted = isset($_SESSION["name"]) && isset($_SESSION['admin']) && $_SESSION['admin'] === true;

	//$_SESSION['admin'] = true;
	//$_SESSION['name'] = "Durss";

	$message = "";

	if(isset($_POST['rights_uid']) && $accessGranted) {
		$uid = (int)$_POST['rights_uid'];
		$rights = $_POST['rights_admin'] == "true"? 1 : 0;
	
		$error = false;
		$message = "Les droits de l'utilisateur ".$uid." ont bien été changés !";
		$sql = 'UPDATE `feverUsers` SET rights='.$rights.' WHERE `uid`= '.$uid;
		try {
			$Mysql->ExecuteSQL($sql);
		}catch (Erreur $e) {
			$error = true;
			$message = "Une erreur est survenue lors de la mise à jour des droits de l'utilisateur ".$uid."...<br /><br />";
			$message .= $e;
		}
	}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd" lang="en">
<html>
	<head>
		<meta http-equiv="Content-Type"  content="text/html; charset=UTF-8" />
		<title>Admins manager</title>
		<style type="text/css">
				
			html, body {
				overflow:auto;
				height:100%;
				margin:0;
				padding:0;
				font-family: Trebuchet MS,Arial,sans-serif;
			}
			body {
				background: url("images/background.png") repeat scroll 0 190px transparent;
				font: 86 % Arial, "Helvetica Neue", sans - serif;
				color:#ffffff;
				margin: 0;
				margin-top: 20px;
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
				margin: auto;
				margin-top: 50px;
				padding-top: 5px;
				text-align: center;
				font-weight: bold;
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
				margin: auto;
				word-wrap: break-word;
			}

			form, label {
				display: block;
			}
			[name="uid"] {
				width: 100px;
			}
			input[type="submit"] {
				display: block;
				margin: auto;
			}

			#section.success {
				background-color: #003300;
			}

			#section.error {
				background-color: #990000;
			}
		</style>
	</head>
	<body>

		<?php
			
			if (!$accessGranted) {
				echo '<div id="title">Accès refusé</div>';
				echo '<div id="section" class="error">Seuls les administrateurs peuvent accéder à cette page.<br />Mais ça ne veut pas dire que je t\'aime moins promis.</div>';
				echo '</body></html>';
				die;
			}

			if(!empty($message)) {
				echo '<div id="section" class="'.($error? 'error' : 'success').'">'.$message.'</div>';
			}
		?>

		<div id="title">Gérer les droits d'admins d'un joueur</div>
		<div id="section">
			<form action="admin.php" method="POST">
				<label><b>User ID : </b><input type="number" name="rights_uid"></label>
				<b>Droits :</b>
				<input type="radio" name="rights_admin" value="true">Admin</input>
				<input type="radio" name="rights_admin" value="false">Non-admin</input>
				<input type="submit" value="Valider">
			</form>
		</div>
		<div id="title">Où trouver l'ID utilisateur :</div>
		<div id="section">
			Rendez-vous sur le profil <b>MUXXU</b> du joueur, son ID se trouvera à la fin de l'URL de la page :<br /><br />
			<img src="images/admin_help.jpg" alt="Trouver le User ID" title="Trouver le User ID">
		</div>
	</body>
</html>