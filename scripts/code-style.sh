#!/usr/bin/env bash

##
# This script checks for coding practises
# It's used so that we can maintain bigger projects in a way that's easy to understand
##

# Get script directory
DIR=$(dirname $(readlink -f "$0"))

##
# Check php coding practises with codesniffer
##
if [ "$WP_ENV" = "testing" ]; then

  # Show only summary in CI environment
  /var/lib/wpcs/vendor/bin/phpcs -n -p --report=summary --standard=$DIR/../ruleset.xml \
    $DIR/../web/

else

  # Check only files in git and not files from plugins/packages
  /var/lib/wpcs/vendor/bin/phpcs --standard=$DIR/../ruleset.xml $(git ls-files | grep .php)

fi
