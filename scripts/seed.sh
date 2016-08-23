#!/usr/bin/env bash

##
# This file is used to create basic starting point content for dev/test/stage/production
##

# Set defaults

# This is for local development where MYSQL_HOST is unknown beforehand
if [ "$MYSQL_HOST" == "" ] && [ "$DB_PORT_3306_TCP_ADDR" != "" ]; then
  MYSQL_HOST=$DB_PORT_3306_TCP_ADDR
fi

# Use default port if not defined
if [ "$MYSQL_PORT" == "" ]; then
  MYSQL_PORT="3306"
fi

# Wait until mysql is open
nc -z $MYSQL_HOST $MYSQL_PORT
if [[ $? != 0 ]] ; then
  echo "Waiting mysql to open in $MYSQL_HOST:$MYSQL_PORT..."
  declare -i i
  while ! nc -z $MYSQL_HOST $MYSQL_PORT; do
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
if [ "$WP_ENV" = "production" ] || [ "$WP_ENV" = "staging" ]; then

  # Don't use seed data in production yet
  echo "Production/Staging don't use seed data at the moment"

elif [ "$WP_ENV" = "development" ] || [ "$WP_ENV" = "testing" ]; then

  phinx seed:run -q

fi
