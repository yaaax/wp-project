#!/bin/bash
set -e

##
# This file is used to create:
# - development database in dev
# - import production database in testing environment (TODO)
# - import migration database if this is new production
##

# Get script directory
DIR=$(dirname $(readlink -f "$0"))

echo "Starting to import database seed..."

if wp core is-installed; then
  echo "Database already exists, updating core tables..."
  wp core update-db
elif ! wp core version; then
  echo "ERROR: Couldn't find wp core. Aborting..."
  exit 1
fi

##
# Add seed or necessary changes to database depending on env
##
if [ "$WP_ENV" = "production" ] || [ "$WP_ENV" = "staging" ]; then

  # Don't use seed data in production yet
  echo "Production/Staging don't use seed data at the moment"

elif [ "$WP_ENV" = "development" ] || [ "$WP_ENV" = "testing" ]; then

  phinx seed:run

fi

##
# Run migrations with phinx
##
phinx migrate -e $WP_ENV
