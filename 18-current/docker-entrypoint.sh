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
