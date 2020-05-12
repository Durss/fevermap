<?php
	require_once(realpath(dirname(__FILE__) . '/Mysql.php'));
	require_once(realpath(dirname(__FILE__) . '/Erreur.php'));
	
	try {
		if (file_exists("debug")) {
			$Mysql = new Mysql($Serveur = 'localhost', $Bdd = 'www_muxxu', $Identifiant = 'root', $Mdp = ''); 
		}else {
			$Mysql = new Mysql($Serveur = 'xxx', $Bdd = 'xxx', $Identifiant = 'xxx', $Mdp = 'xxx'); 
		}
	}
	catch (Erreur $e) {
		echo $e -> RetourneErreur();
	}
	
?>