<?php

// Connecting, selecting database
$link = mysql_connect(getenv('ELGG_DB_HOST'), getenv('ELGG_DB_USER'), getenv('ELGG_DB_PASS'));
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
