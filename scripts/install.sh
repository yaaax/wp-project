#!/bin/bash
set -e

# Get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install composer dependencies
composer install --working-dir=$DIR/../
