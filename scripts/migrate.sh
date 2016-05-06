#!/bin/bash
set -e

##
# This file is used to do migrations which have happened during development
##

# Get script directory
DIR=$(dirname $(readlink -f "$0"))

echo "Starting to run database migrations..."

if wp core is-installed; then
  echo "Database already exists, updating core tables..."
  wp core update-db
elif ! wp core version; then
  echo "ERROR: Couldn't find wp core. Aborting..."
  exit 1
fi

##
# Run migrations with phinx
##
phinx migrate -e $WP_ENV
