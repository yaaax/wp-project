##
# Nothing beats the original Makefile for simplicity
##

# Load few settings in variables
CONTAINER_ID = $(shell docker-compose ps -q web)
SERVER_NAME = $(shell docker exec $(CONTAINER_ID) printenv SERVER_NAME)
DNS_SERVER = 10.254.254.254
PHP_FILES = $(shell git ls-files | grep .php)

# This alias runs all comands
init: start install build seed
all: init test

# This is list of typical commands needed in development
start:
	gdev up
# Installs dependencies
install:
	composer install --ignore-platform-reqs
# Builds frontend assets
build:
	docker-compose run --rm webpack-builder
# Installs databases
seed:
	docker exec -it $(CONTAINER_ID) ./scripts/seed.sh
clean:
	gdev stop
	gdev rm -f
# Run tests
# - Integration tests  defined in /tests/rspec/
# - PHP Codesniffer tests for the files in Git
# - Show sitespeed/coach performance/accessibility metrics
# - Show sitespeed budget
test:
	docker-compose run --rm style-test phpcs --runtime-set ignore_warnings_on_exit true --standard=phpcs.xml $(PHP_FILES)
	docker-compose run --rm browser-test rspec /tests/rspec/test.rb
	docker run --rm --privileged --dns $(DNS_SERVER) sitespeedio/coach https://$(SERVER_NAME) -b chrome --details --description
	docker run --rm --privileged --dns $(DNS_SERVER) -v $(shell pwd)/tests:/sitespeed.io sitespeedio/sitespeed.io --budget sitespeed-budget.json -b chrome -n 2 https://$(SERVER_NAME)

# Fix codesniffer errors automatically
beatify:
	docker-compose run --rm style-test phpcbf --standard=phpcs.xml $(PHP_FILES)
