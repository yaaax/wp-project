---
layout: page
title: "Changelog"
category: info
date: 2016-11-30 11:31:16
order: 1
---

## v20170112.0
* Added `NGINX_CACHE_KEY` so that nginx http caching keys used for redis can be changed per project.

## v20161220.0
* Fix Dockerfile so that files like `web/favicon.ico` will be installed into the container.

## v20161130.0
* Changed envs `WP_UID` and `WP_GID` to `WEB_UID` and `WEB_GID`
* Added [devgeniem/wp-security-collection](https://github.com/devgeniem/wp-security-collection) package into composer.json

## v20161123.0
* Added nginx templating with `*.tmpl` files. [Read related docs on *.tmpl templates]({% post_url 2016-11-29-tmpl-templating %}).
* Added environment specific nginx configurations with nginx/environments folder. [Read about custom includes in docs]({% post_url 2016-11-29-custom-includes %}).
* Added new version of webpack assets builder back to docker-compose.yml for automatic asset building
* Added Makefile for easy shortcuts
