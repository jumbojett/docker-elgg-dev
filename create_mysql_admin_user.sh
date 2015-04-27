#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

echo "=> Creating MySQL user ${MYSQL_USER}."

mysql -uroot -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION"
mysql -uroot -e "CREATE DATABASE ${ELGG_DB_NAME}"
mysql -uroot -e "FLUSH PRIVILEGES"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
if [ "${SHOW_CREDENTIALS}" -eq 1 ]; then
    echo "    mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h<host> -P<port>"
else
    echo "    mysql -u${MYSQL_USER} -p<pass> -h<host> -P<port>"
fi
echo ""
echo "========================================================================"