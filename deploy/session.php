<?php
	header('P3P: CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');
	if(isset($_GET["SESSID"])) {
		session_id($_GET["SESSID"]);
	}
	session_start();
?>