<?php
	header('P3P: CP="CAO PSA OUR"'); 
	session_start();
	
	$betaMode = false;
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org");
		die;
	}
	if (isset($_GET["act"]) && $_GET["act"] == "stats") {
		header("location:stats.php");
		die;
	}
	//header('Content-type: text/html; charset=iso-8859-1');
	$pseudo = "goAwayDude!";
	if(isset($_GET['uid'], $_GET['pubkey'])) {
		$url = "http://muxxu.com/app/xml?app=fevermap&xml=user&id=".$_GET['uid']."&key=".md5("d1268d376ba9e54593b4ca03c756f1a1" . $_GET["pubkey"]);
		$xml = file_get_contents($url);
		preg_match('/name="(.*?)"/', $xml, $matches); //*? = quantificateur non gourmand
		if (strpos($xml, "<error>") === false) {
			$pseudo	= $matches[1];
		}
	}
	
	/**
	 * Checks if a user is on the authorized groups.
	 */
	function isUserOnGroup($pseudo, $url) {
		if (strtolower($pseudo) == "eole" || strtolower($pseudo) == "newsunshine") return true;
		
		$handle = fopen($url, "rb");
		$content = '';
		while (!feof($handle)) {
		  $content .= fread($handle, 8192);
		}
		fclose($handle);
		
		$result = str_replace("\n", "", $content);
		$result = str_replace("\r", "", $result);
		$result = preg_replace('/"prevuser".*<\/li>/imU', "", $result);
		
		return stripos($result, $pseudo) !== false;
	}
	if($betaMode) {
		$authorized = isUserOnGroup($pseudo, "http://muxxu.com/g/fever-addicts/members");
		$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/bak-elites/members", "r");
		$authorized = $authorized || isUserOnGroup($pseudo, "http://muxxu.com/g/atlantes/members", "r");
		if ($authorized) {
			$_SESSION["betaSession2"] = true;
		}
	}else {
		$authorized = true;
	}
	
	//Redirect the user
	if ($betaMode && !$authorized && !isset($_SESSION["betaSession2"])) {
		header("location: ./maintenance/");
	}else {
		$_SESSION["logged"] = true;
		header("Cache-Control: no-cache, must-revalidate");
		header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	}
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">
	<head>
		<title>FeverMap</title>
		<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
		<link rel="shortcut icon" href="./favicon_new.ico" />
		<style type="text/css">
		html, body {
			overflow:hidden;
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
			color:#E20C0C;
			text-decoration:none;
		}
		a:hover {
			color:#F42D2D;
		}
		#copyLink {
			color:#CC0000;
			font-size: 12px;
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
		
		.airLink {
			font-size: 30px;
			font-weight:bold;
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
<?php
	if (isset($_GET["act"]) &&  substr($_GET["act"], 0, 4) == "lang") {
		 $_GET["lang"] = substr($_GET["act"], 5);
	}
	if (isset($_GET["act"]) && $_GET["act"] == "ids") {
?>
		<center>
			<br /><br /><br /><br />
			<div id="title">Voici vos identifiants de connexion :</div>
			<div id="section">Ces valeurs sont à renseigner dans les champs du même nom au sein de l'application si vous l'utilisez en dehors de muxxu :<br /><br />
			UID : <b><?php echo $_GET["uid"]; ?></b><br />
			PUBKEY : <b id="pubkey"><?php echo htmlentities($_GET["pubkey"]); ?></b> &nbsp;&nbsp;&nbsp;&nbsp;<b id="copyLink">Copier</b>
			</div>
		</center>
		
		<script language="JavaScript">
			var clip = null;
			ZeroClipboard.setMoviePath('swf/ZeroClipboard10.swf');

			function $(id) { return document.getElementById(id); }

			function init() {
				clip = new ZeroClipboard.Client();
				clip.setHandCursor(true);
				clip.setText( $('pubkey').innerHTML );
				clip.glue('copyLink');
			}
			window.onload = init;
		</script>
<?php
	} elseif (isset($_GET["act"]) && $_GET["act"] == "desktop") {
?>

		<center>
			<br /><br /><br /><br />
			<div id="title">Version desktop</div>
			<div id="section">Téléchargez la version desktop de la Fevermap pour plus de confort d'utilisation.<br /><br />
			<a href="FeverMap.air"><img src="images/air.png" style="position:relative; top:12px; margin-right:10px;" /><span class="airLink">Télécharger .AIR</span></a><br/><br/>
			Si après téléchargement le fichier se retrouve sous forme d'archive nommé <b>FeverMap.ZIP</b> alors renomez le fichier en <b>FeverMap.AIR</b> puis exécutez-le.<br />
			Pensez à <a href="http://get.adobe.com/fr/air/">installer le runtime AIR</a> au préalable pour pouvoir installer l'application.</div>
		</center>

<?php
	} else {
?>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 10.1+ support!</p>
		</div>
		
		<script type="text/javascript">
			// <![CDATA[
			var so = new SWFObject('swf/FeverMap.swf?v=45', 'content', '100%', '100%', '10.1', '#412720');
			so.useExpressInstall('swf/expressinstall.swf');
			so.addParam('menu', 'false');
			so.addParam('allowFullScreen', 'true');
			so.addVariable("configXml", "./config.php?lang=<?php echo $_GET["lang"]; ?>");
<?php
	if (isset($_GET["uid"], $_GET["pubkey"])) {
		echo "\t\t\tso.addVariable('uid', '".htmlentities($_GET["uid"])."');\r\n";
		echo "\t\t\tso.addVariable('pubkey', '".htmlentities($_GET["pubkey"])."');\r\n";
	}
	if (isset($_GET["x"], $_GET["y"])) {
		echo "\t\t\tso.addVariable('x', '".$_GET['x']."');\r\n";
		echo "\t\t\tso.addVariable('y', '".$_GET['y']."');\r\n";
	}
	if (isset($_GET["zoom"])) {
		echo "\t\t\tso.addVariable('zoom', '".$_GET['zoom']."');\r\n";
	}
?>
			so.write('content');
			/*]]>*/

			function reload() {
				setTimeout("location.reload()", 2000);
			}
		</script>
<?php
	}
?>
	</body>
</html>