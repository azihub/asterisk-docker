#!/bin/sh


# run as user asterisk by default
ASTERISK_USER=${ASTERISK_USER:-asterisk}

if [ "$DEBUG" = "true" ]; then
  COMMAND="/usr/sbin/asterisk -T -W -X -p -ddd -vvvdddf"
else
  COMMAND="$@"
fi

touch /etc/asterisk/configs.d/res_config_mysql.conf
if [ ! -z "${MYSQL_DB_NAME}" ]; then
  if [ ! -z "${MYSQL_DB_NAME}" ]; then
    cp /usr/src/asterisk/contrib/ast-db-manage/config.ini.sample /usr/src/asterisk/contrib/ast-db-manage/config.ini
    sed -i "s/sqlalchemy.url = mysql:\/\/user:pass@localhost\/asterisk/sqlalchemy.url = mysql:\/\/$MYSQL_DB_USER:$MYSQL_DB_PASS@localhost\/$MYSQL_DB_NAME/" /usr/src/asterisk/contrib/ast-db-manage/config.ini
    alembic -c config.ini upgrade head
  fi
  echo "
[asterisk]
Driver = MySQL
Description = MySQL connection to ‘asterisk’ database
Server = $MYSQL_DB_HOST
Port = ${MYSQL_DB_PORT:-3306}
Database = $MYSQL_DB_NAME
UserName = $MYSQL_DB_USER
Password = $MYSQL_DB_PASS
Socket = ${MYSQL_DB_SOCKET:-/var/run/mysqld/mysqld.sock}" > /etc/odbc.ini
  echo "[general]
  dbhost = $MYSQL_DB_HOST
  dbname = $MYSQL_DB_NAME
  dbuser = $MYSQL_DB_USER
  dbpass = $MYSQL_DB_PASS
  dbport = ${MYSQL_DB_PORT:-3306}
  dbsock = ${MYSQL_DB_SOCKET:-/tmp/mysql.sock}
  dbcharset = latin1
  requirements=warn ; or createclose or createchar
  " > /etc/asterisk/configs.d/res_config_mysql.conf
fi

chown -R 1000:1000 /etc/asterisk \
                   /var/lib/asterisk \
                   /var/run/asterisk \
                   /usr/lib/asterisk


exec ${COMMAND}
