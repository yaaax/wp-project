# Geniem Wordpress Project template.
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

Use this with our docker-image: [devgeniem/alpine-wordpress](https://github.com/devgeniem/docker-alpine-wordpress).

And our development tools: [gdev](https://github.com/devgeniem/gdev).

## Features
- This resembles [roots/bedrock](https://github.com/roots/bedrock) project layout.
- Uploads directory has been moved into /var/www/uploads (locally mapped into .docker/uploads)
- Uses composer for installing plugins
- Include `.drone.yml` for using [Drone CI](https://github.com/drone/drone).
- Includes phantomjs tests through rspec for doing integration testing. Source: [Seravo/wordpress](https://github.com/Seravo/wordpress).

## Workflow for WP projects
1. Replace all `THEMENAME` and `PROJECTNAME` references from your project to your project name.
    * These can be for example: `ClientName` and `client-name`
2. Add project participants into `composer.json` `authors` and rename the project `devgeniem/wp-project`->`devgeniem/client`.
    * You can also add project managers, designers and other developers here.
    * This is important so that we always have accountable people to advise with the project later on when it eventually might turn to more legacy project.
3. Setup minimun viable content seed in phinx seeds so that CI can reliably do the tests.
4. Use included linters for the code style and best practises
    * For now this project only includes `phpcs.xml` for php codesniffer Geniem Coding Standards.
    * This ruleset is here to help and make the developer to think about possible vulnerabilities.
    * When something doesn't fit into the ruleset you can ask for a code review and add comments to ignore certain line:
    ```php
    // @codingStandardsIgnoreStart
    $query_string  = filter_var($_SERVER['QUERY_STRING'], FILTER_SANITIZE_STRING)
    // @codingStandardsIgnoreEnd
    ```
5. Add more `rspec` or `phpunit` tests while you continue to add features to your site.
    * This helps us to avoid regressions and will enable more agile refactoring of the code when needed.
6. Try to update this Readme as many times as you can.
    * Most important details are usually the details about data models and their input/output.
    * Also add all 3rd-party dependencies here

## Start local development
This project includes example `docker-compose.yml` which you can use to develop locally.

```
$ docker-compose up -d
```
