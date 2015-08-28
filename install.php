<?php
/**
 * Docker CLI installer script.
 */

if (PHP_SAPI !== 'cli') {
	echo "You must use the command line to run this script.\n";
	exit(1);
}

if (file_exists("/app/install/ElggInstaller.php")) {
	require_once "/app/install/ElggInstaller.php";
} else if (file_exists("/app/engine/classes/ElggInstaller.php")) {
	require_once "/app/engine/classes/ElggInstaller.php";
} else {
	echo "Cannot find Elgg installer.";
	exit(1);
}

$installer = new ElggInstaller();

// none of the following may be empty
$params = array(
	// database parameters
	'dbuser' => getenv('ELGG_DB_USER'),
	'dbpassword' => getenv('ELGG_DB_PASS'),
	'dbname' => getenv('ELGG_DB_NAME'),
	'dbhost' => getenv('ELGG_DB_HOST'),
	'dbprefix' => getenv('ELGG_DB_PREFIX'),

	// site settings
	'sitename' => getenv('ELGG_SITE_NAME'),
	'siteemail' => getenv('ELGG_SITE_EMAIL'),
	'wwwroot' => getenv('ELGG_WWW_ROOT'),
	'dataroot' => getenv('ELGG_DATA_ROOT'),

	// admin account
	'displayname' => getenv('ELGG_DISPLAY_NAME'),
	'email' => getenv('ELGG_EMAIL'),
	'username' => getenv('ELGG_USERNAME'),
	'password' => getenv('ELGG_PASSWORD'),
	'path' => getenv('ELGG_PATH')
);

// exit early if errors
if (strlen($params['password']) < 6) {
    echo "Elgg Admin password must be at least 6 characters long.\n";
    exit(1);
}

// install and create the .htaccess file
$installer->batchInstall($params, true);

// at this point installation has completed (otherwise an exception halted execution).
exit(0);
