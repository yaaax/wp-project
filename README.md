# Geniem Wordpress Project template.

Use this with our docker-image: [devgeniem/alpine-wordpress](https://github.com/devgeniem/docker-alpine-wordpress).

And our development tools: [gdev](https://github.com/devgeniem/gdev).

## Features
- This resembles [roots/bedrock](https://github.com/roots/bedrock) project layout.
- Uploads directory has been moved into /data/uploads (locally mapped into .docker/uploads)
- Uses composer for installing plugins
- Include `.drone.yml` for using [Drone CI](https://github.com/drone/drone).
- Includes phantomjs tests through rspec for doing integration testing. Source: [Seravo/wordpress](https://github.com/Seravo/wordpress).

## Start local development
This project includes example `docker-compose.yml` which you can use to develop locally.

```
$ docker-compose up -d
```