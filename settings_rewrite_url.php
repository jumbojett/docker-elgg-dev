
// appended to engine/settings.php to set the url and port

require_once '/GetHost.php';
require_once '/app/engine/settings.php';

$gh = new GetHost();
$url = rtrim($gh->getBaseUrl(), '/') . '/';

$link = mysql_connect($CONFIG->dbhost, $CONFIG->dbuser, $CONFIG->dbpass, true);
mysql_select_db($CONFIG->dbname, $link);
$result = mysql_query("UPDATE {$CONFIG->dbprefix}sites_entity set url='$url'", $link);
mysql_close($link);
