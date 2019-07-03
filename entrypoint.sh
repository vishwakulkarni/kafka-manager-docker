#!/bin/bash

export APPLICATION_SECRET="${APPLICATION_SECRET:-$(date +%s | sha256sum | base64 | head -c 64 ; echo)}"
export HTTP_CONTEXT="${HTTP_CONTEXT:-/}"
export ZK_HOSTS="${ZK_HOSTS:-zookeeper:2181}"
export BASE_ZK_PATH="${BASE_ZK_PATH:-/kafka-manager}"
export KAFKA_MANAGER_LOGLEVEL="${KAFKA_MANAGER_LOGLEVEL:-INFO}"
export LOGGER_STARTUP_TIMEOUT="${LOGGER_STARTUP_TIMEOUT:-60s}"
KAFKA_MANAGER_CONFIG="${KAFKA_MANAGER_CONFIG:-./conf/application.conf}"
HTTP_PORT="${HTTP_PORT:-9000}"

export ZK_HOSTS=$(echo $VCAP_SERVICES | jq -r .kafka[0].credentials.cluster.zk)

exec /app/bin/kafka-manager  -Dconfig.file=${KAFKA_MANAGER_CONFIG} -Dhttp.port=${HTTP_PORT} "${KAFKA_MANAGER_ARGS}" "${@}"
