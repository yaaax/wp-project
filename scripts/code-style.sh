#!/usr/bin/env bash

##
# This script checks for coding practises
# It's used so that we can maintain bigger projects in a way that's easy to understand
##

# Get script directory
DIR=$(dirname $(readlink -f "$0"))

##
# Check php coding practises with codesniffer
# - check only files in git and not files from plugins/packages
##
if [ "$WP_ENV" = "testing" ]; then

  # Show only summary in CI environment
  /var/lib/wpcs/vendor/bin/phpcs -n -p --report=summary --standard=$DIR/../phpcs.xml $(git ls-files | grep .php)

else

  /var/lib/wpcs/vendor/bin/phpcs --standard=$DIR/../phpcs.xml $(git ls-files | grep .php)

fi
