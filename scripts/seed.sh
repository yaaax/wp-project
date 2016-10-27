#!/usr/bin/env bash

##
# This file is used to create basic starting point content for dev/test/stage/production
##

# Set defaults
export DB_HOST=${DB_PORT_3306_TCP_ADDR-$DB_HOST}
export DB_PORT=${MYSQL_PORT-$DB_PORT}

# Wait until mysql is open
nc -z $DB_HOST $DB_PORT
if [[ $? != 0 ]] ; then
  echo "Waiting mysql to open in $DB_HOST:$DB_PORT..."
  declare -i i
  while ! nc -z $DB_HOST $DB_PORT; do
    if [ "$i" == "15" ]; then
      echo "Error: Mysql process timeout"
      exit 1
    fi
    i+=1
    sleep 1
  done
fi

# Fail after errors
set -e


# Get script directory
DIR=$(dirname $(readlink -f "$0"))

echo "Starting to import database seed..."

##
# Add seed or necessary changes to database depending on env
##
phinx seed:run -q
