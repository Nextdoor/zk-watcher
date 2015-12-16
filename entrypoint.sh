#!/bin/bash

export

# Default configuration variables
DOCKER_HOST_IP=$(route -n | awk '/UG[ \t]/{print $2}')
ZOOKEEPER_HOST=${ZOOKEEPER_HOST:-$DOCKER_HOST_IP}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
VERBOSE=${VERBOSE:-}

# Default Service Healthcheck Config
DEFAULT_PROTO=http
DEFAULT_URL=/
DEFAULT_REFRESH=30
DEFAULT_HOSTNAME=${DOCKER_HOST_IP}

# Generate our CLI options
if [[ -z "$VERBOSE" ]]; then
  VERBOSE_ARG=-v
fi

# docker service regex
create_config_section() {
  URL=SERVICE_${COUNT}_PORT
  PORT=$(echo ${!URL} | cut -d : -f 2)
  ADDR=SERVICE_${COUNT}_PORT_${PORT}_TCP_ADDR

  cat << EOF
[$1]
cmd: curl --silent --fail ${PROTO}://${!ADDR}:${PORT}/${!URL}
refresh: ${DEFAULT_REFRESH}
service_port: ${PORT}
service_hostname: ${DEFAULT_HOSTNAME}
zookeeper_path: /services/us1/us-west-2/db/nextdoor/standby
zookeeper_data: hostname=us1-nextdoor-db2-uswest2-i-c9d2400d,puppet_environment=production,
EOF
}

# For each possible Docker "link" (1 -> 100), 
COUNT=0
while [ $COUNT -lt 101 ]; do
  NAME=SERVICE_${COUNT}_NAME

  if [[ ${!NAME} ]]; then
    echo "Generating configuration for link: ${!NAME}"
    create_config_section ${!NAME}
  fi

  COUNT=$[$COUNT+1]
done

exit 0
exec /usr/bin/zk_watcher \
	--server ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} \
	$VERBOSE_ARG
