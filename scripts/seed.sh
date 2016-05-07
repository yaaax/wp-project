#!/bin/bash
set -e

##
# This file is used to create basic starting point for dev/test/stage/production
##

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
