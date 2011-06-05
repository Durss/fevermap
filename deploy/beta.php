<?php
	session_start();
	header('Content-type: text/html; charset=UTF-8');
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	if (!isset($_SESSION["userID"]) || strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org");
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">
	<head>
		<title>FeverMap</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<link rel="shortcut icon" href="./favicon.ico" />
		<style type="text/css">
            html, body {
				overflow:hidden;
				height:100%;
                margin:0;
                padding:0;
            }
            body {
                background: #ffffff;
                font: 86% Arial, "Helvetica Neue", sans-serif;
                margin: 0;                
            }
            #content {
                height: 100%;
            }
            .warning {
                color: #cc0000;
				font-weight:bold;
            }
		</style>
		
		<script type="text/javascript" src="js/swfobject.js"></script>
    </head>
    <body>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 10+ support!</p>
		</div>
		
		<script type="text/javascript">
			// <![CDATA[
            var so = new SWFObject('FeverMap_beta.swf?v=3', 'content', '100%', '100%', '10', '#ffffff');
            so.useExpressInstall('swf/expressinstall.swf');
            so.addParam('menu', 'false');
            so.addParam('allowFullScreen', 'true');
			so.addVariable("configXML", "xml/config.xml?v=1");
            so.write('content');
			/*]]>*/
			
			function reload() {
				setTimeout("location.reload()", 2000);
			}
        </script>
    </body>
</html>