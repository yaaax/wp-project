#!/usr/bin/env bash

##
# This script checks for coding practises
# It's used so that we can maintain bigger projects in a way that's easy to understand
##

# Get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

##
# Check php coding practises with codesniffer
# - check only files in git and not files from plugins/packages
##
if [ "$WP_ENV" = "testing" ]; then
    set -x
    # Show only summary in CI environment
    phpcs -n -p --report=summary --standard=$DIR/../phpcs.xml .
else
    set -x
    phpcs --standard=$DIR/../phpcs.xml .
fi
