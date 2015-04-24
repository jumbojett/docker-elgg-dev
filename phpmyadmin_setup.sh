#!/usr/bin/expect

spawn dpkg-reconfigure phpmyadmin -freadline
expect "Reinstall database for phpmyadmin?"
send "N\r"

expect "Please choose the web server that should be automatically configured to run phpMyAdmin."
sent "1\r"

expect eof
