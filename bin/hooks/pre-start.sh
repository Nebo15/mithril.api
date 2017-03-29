#!/bin/sh
# `pwd` should be /opt/trump_api
APP_NAME="trump_api"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "${APP_NAME}_tasks" migrate!
fi;
