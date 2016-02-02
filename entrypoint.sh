#!/bin/bash

# Exit on *any* failure
set -e

# Default configuration variables
DOCKER_HOST_IP=$(route -n | awk '/UG[ \t]/{print $2}')
ZOOKEEPER_HOST=${ZOOKEEPER_HOST:-$DOCKER_HOST_IP}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
VERBOSE=${VERBOSE:-}
REFRESH=${REFRESH:-30}
DRAIN_TIME=${DRAIN_TIME:-0}

# The service_hostname that we register is tricky -- it *most likely* should be
# the public hostname/ip of the docker machine itself. This is not something
# thats discoverable though in the container. We do allow the user to pass it
# in (as SVC_HOST) -- but if they don't, we try to discover it from a
# volume-mapped file in the container.
#
# You can do something like:
#   docker_host$ hostname > /tmp/myhostname
#   docker_host$ docker run --volume /tmp/myhostname:/tmp/hostname ...
#
if [[ -z "$SVC_HOST" ]] && [[ -e /tmp/hostname ]]; then
  SVC_HOST=$(cat /tmp/hostname)
  echo "Discovered my hostname ($SVC_HOST) from /tmp/hostname..."
fi

# Generate our CLI options
if [[ ! -z "$VERBOSE" ]]; then
  VERBOSE_ARG=-v
fi

# Ensure that the required variables have been set in some way
declare -a WANTED_VARS=("CMD" "REFRESH" "SVC_PORT" "SVC_HOST" "ZK_PATH")
for VAR in "${WANTED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo "Missing $VAR."
    exit 1
  fi
done

# Generate the fresh configuration file
cat << EOF > /zk_watcher.cfg
[service]
cmd: $(eval echo ${CMD})
refresh: ${REFRESH:-DEFAULT_REFRESH}
service_port: $(eval echo ${SVC_PORT})
service_hostname: ${SVC_HOST}
zookeeper_path: ${ZK_PATH}
EOF

echo "Starting zk_watcher up with the following config:"
cat /zk_watcher.cfg

sigterm() {
  echo "Received SIGTERM... Shutting down."
  kill -TERM $(cat /pidfile)
  echo "Sleeping for ${DRAIN_TIME}s before exiting..."
  sleep $DRAIN_TIME
}
trap 'sigterm' TERM INT

zk_watcher \
  --server ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} \
  --config /zk_watcher.cfg \
  $VERBOSE_ARG &
echo $! > /pidfile

while true; do
  echo "Weee"
  wait %1
  echo "waiting"
done
