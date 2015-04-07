# docker-elgg-dev
Elgg development environment on docker.

# Quick start
1. Download or clone the Elgg version you want to work with.
2. Run the docker image mounting Elgg as the volume /app. If you're on Windows or OS X
   and use boot2docker, remember it mounts your C:\Users or /Users directory in the 
   dev VM, so adjust paths accordingly.
3. There are a number of environment variables that affect how the the container is built.
   See run.sh for a list.
4. After the container is built, the credentials for Elgg and MySQL if not supplied are printed
   if they weren't supplied via enviroment variables.
5. Depending on how you're running docker, you may need to expose ports. You can easily
   expose all ports by using `docker run -P ...`.
6. Open the docker vm's IP address and port in your browser. If you're using Kitematic,
   just click on the preview image and it will open for you. You can also browse to
   /phpmyadmin for a phpmyadmin installation. Check the docker screen for the 
   mysql root password.

# Environmental Vars

Setting environmental vars with -e VAR="value" affects the behavior of the installation.
If none are given, defaults are used and output on the screen

* `MYSQL_USER` The DB username to create
* `MYSQL_PASS` The DB password to set on the created user
* `ELGG_DB_HOST` The DB host Elgg will use
* `ELGG_DB_USER` The DB user Elgg will use
* `ELGG_DB_PASS` The DB password Elgg will use
* `ELGG_DB_PREFIX` Elgg's DB prefix 
* `ELGG_DB_NAME` The name of the DB Elgg will use
* `ELGG_SITE_NAME` Elgg's site name
* `ELGG_SITE_EMAIL` Elgg site email address 
* `ELGG_WWW_ROOT` Elgg's www_root (Don't change this unless you modify run.sh and the installation)
* `ELGG_DATA_ROOT` The data_root for Elgg (/media)
* `ELGG_DISPLAY_NAME` The display name for the admin user
* `ELGG_EMAIL` The email address for the admin user (must be a well-formed, though not necessarily value, address)
* `ELGG_USERNAME` The username of the admin user
* `ELGG_PASSWORD` The password for the admin user
* `ELGG_PATH` The location Elgg is installed (Don't change this unless you modify run.sh and the installation)
* `ELGG_SITE_ACCESS` The default site access
* `REINSTALL` Should Elgg force a reinstall? THIS WILL DELETE engine/settings.php AND .htaccess!

# Example
Replace `/path/to/elgg/clone/` with the actual path to you Elgg clone. Note that this will overwrite your settings.php and htaccess files!


`docker run -p 8080:80 -e REINSTALL=1 -e ELGG_PASSWORD='asdfjkl' -v /Users/brett/Devel/elgg/:/app jumbojett/elgg-dev-environment`
