##
# Nothing beats the original Makefile for simplicity
##

# This is list of typical commands needed in development
start:
	gdev up
install:
	composer update --ignore-platform-reqs
clean:
	gdev stop
	gdev rm -f
test: start
	gdev run test /var/www/project/scripts/test.sh
build:
	gdev run webpack-builder
