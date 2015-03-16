<?php

class GetHost {
	/**
	 * @return bool Whether the install process is encrypted.
	 */
	private function isHttps() {
		return (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") ||
			$_SERVER['SERVER_PORT'] == 443;
	}

	/**
	 * Get the best guess at the base URL
	 *
	 * @note Cannot use current_page_url() because it depends on $this->CONFIG->wwwroot
	 * @todo Should this be a core function?
	 *
	 * @return string
	 */
	public function getBaseUrl() {
		$protocol = $this->isHttps() ? 'https' : 'http';

		if (isset($_SERVER["SERVER_PORT"])) {
			$port = ':' . $_SERVER["SERVER_PORT"];
		} else {
			$port = '';
		}
		if ($port == ':80' || $port == ':443') {
			$port = '';
		}
		$uri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';
		$cutoff = strpos($uri, 'install.php');
		$uri = substr($uri, 0, $cutoff);
		$serverName = isset($_SERVER['SERVER_NAME']) ? $_SERVER['SERVER_NAME'] : '';

		return "$protocol://{$serverName}$port{$uri}";
	}
}
