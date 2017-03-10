#!/bin/bash
set -e

# Log to tty to enable docker logs container-name
sed -i "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

# Update users and roles with if username and password is passed as argument
if [[ "$ARTEMIS_USERNAME" && "$ARTEMIS_PASSWORD" ]]; then
  sed -i "s/artemis=amq/$ARTEMIS_USERNAME=amq/g" ../etc/artemis-roles.properties
  sed -i "s/artemis=simetraehcapa/$ARTEMIS_USERNAME=$ARTEMIS_PASSWORD/g" ../etc/artemis-users.properties
fi

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -i "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -i "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

if [ "$1" = 'artemis-server' ]; then
	set -- gosu artemis "./artemis" "run"
fi

sed -i "s/node_type/${ARTEMIS_REPLICATION_TYPE:-master}/g" /var/lib/artemis/etc/broker.xml

ip=$(grep `hostname` /etc/hosts | awk '{print $1}')
sed -i "s/0.0.0.0/${ip:-0.0.0.0}/g" /var/lib/artemis/etc/broker.xml
sed -i "s/DEBUG_ARGS/DEBUG_ARGS -Djava.net.preferIPv4Stack=true/g" /var/lib/artemis/bin/artemis

exec "$@"