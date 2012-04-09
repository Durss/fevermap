<?php
	require_once(realpath(dirname(__FILE__) . '/Mysql.php'));
	require_once(realpath(dirname(__FILE__) . '/Erreur.php'));
	
	try {
		if (file_exists("debug")) {
			$Mysql = new Mysql($Serveur = 'localhost', $Bdd = 'www_muxxu', $Identifiant = 'root', $Mdp = ''); 
		}else {
			$Mysql = new Mysql($Serveur = 'mysql5-21.bdb', $Bdd = 'fevermapmysql', $Identifiant = 'fevermapmysql', $Mdp = 'reyhPGwW'); 
		}
	}
	catch (Erreur $e) {
		echo $e -> RetourneErreur();
	}
	
?>