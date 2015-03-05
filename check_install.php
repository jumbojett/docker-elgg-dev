<?php

function install () {
	header("Location: install.php");
	exit;
}

// Connecting, selecting database
$link = mysql_connect('localhost', 'root', '')
    or install();

$result = mysql_query("SHOW TABLES FROM elgg");
if(mysql_num_rows($result) <= 0) install();

// Free resultset
mysql_free_result($result);

// Closing connection
mysql_close($link);
?>