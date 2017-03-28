#!/bin/bash
#set -e
whoami

# Log to tty to enable docker logs container-name
sed -i "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

echo 1

# Update users and roles with if username and password is passed as argument
if [[ "$ARTEMIS_USERNAME" && "$ARTEMIS_PASSWORD" ]]; then
  sed -i "s/artemis=amq/$ARTEMIS_USERNAME=amq/g" ../etc/artemis-roles.properties
  sed -i "s/artemis=simetraehcapa/$ARTEMIS_USERNAME=$ARTEMIS_PASSWORD/g" ../etc/artemis-users.properties
fi

echo 2

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -i "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

echo 3

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -i "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

echo 4

if [ "$1" = 'artemis-server' ]; then
	set -- gosu artemis "./artemis" "run"
fi

echo 5

sed -i "s/node_type/${ARTEMIS_REPLICATION_TYPE:-master}/g" /var/lib/artemis/etc/broker.xml

echo 6

ip=$(grep `hostname` /etc/hosts | awk '{print $1}')

echo 7

sed -i "s/0.0.0.0/${ip:-0.0.0.0}/g" /var/lib/artemis/etc/broker.xml

echo 8

sed -i "s/DEBUG_ARGS/DEBUG_ARGS -Djava.net.preferIPv4Stack=true/g" /var/lib/artemis/bin/artemis

echo 9

exec "$@"

echo 10