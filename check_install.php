<?php

// Connecting, selecting database
@include '/app/engine/settings.php';

if (!isset($CONFIG)) {
    var_dump("No config");
    exit(1);
}

$link = mysql_connect($CONFIG->dbhost, $CONFIG->dbuser, $CONFIG->dbpass);
$result = mysql_query("SHOW TABLES FROM elgg");

if (mysql_num_rows($result) <= 0) {
    var_dump(mysql_error());
    var_dump("No DB");
    exit(1);
}

// Free resultset
mysql_free_result($result);

// Closing connection
mysql_close($link);

exit(0);