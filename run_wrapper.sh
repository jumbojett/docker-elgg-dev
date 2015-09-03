#!/bin/bash
file=/var/run/mysqld/mysqld.sock
while [[ ! -e $file ]]
do
    inotifywait -qq -e create -e moved_to "$(dirname $file)"
done

cd /
. run.sh ; sv stop elgg-setup
