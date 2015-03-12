
// appended to engine/settings.php to set the url and port

require_once '/app/install/ElggInstaller.php';
require_once '/app/engine/settings.php';

// it's a protected function >:O
class ElggHostChecker extends ElggInstaller {
    public function __construct() {
        // noop
    }

    public function getBaseUrl() {
        return parent::getBaseUrl();
    }
}


$install = new ElggHostChecker();
$url = rtrim($install->getBaseUrl(), '/') . '/';

$link = mysql_connect($CONFIG->dbhost, $CONFIG->dbuser, $CONFIG->dbpass, true);
mysql_select_db($CONFIG->dbname, $link);
$result = mysql_query("UPDATE {$CONFIG->dbprefix}sites_entity set url='$url'", $link);
mysql_close($link);