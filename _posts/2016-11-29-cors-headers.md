---
layout: page
title: "CORS headers"
category: nginx
date: 2016-11-29 13:26:35
order: 6
---

Cross-Origin Resource Sharing headers aka CORS headers tell your site which other sites can require assets from this domain.

It's quite bad header because it doesn't support multiple domains in the header and we need to use hacks like below to bypass these restrictions:

## Example: Allow multisite sites

By default WordPress multisites enqueue all assets from the domain of main site defined with: `define( 'DOMAIN_CURRENT_SITE', 'multisite.example.com';`

You can use `map` directive to allow only certain domains from accessing your assets.

Use map in `nginx/http/cors-map.conf` like this:

```
# This file tells nginx server block to send right CORS headers
# We prefer map instead of nginx if, because if is evil

map $http_origin $cors_host {
    hostnames;

    default       'multisite.example.com';

    # Allow all subdomains to access these assets
    *.multisite.example.com $http_origin;
}
```

And then use the `$cors_host` variable in `nginx/server/cors-headers.conf` like this:

```
##
# Allow multisite subdomains with dynamic CORS headers
# see ../http/cors-map.conf for more
##
add_header 'Access-Control-Allow-Origin' $cors_host;
add_header 'Access-Control-Allow-Methods' 'GET,POST';
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Headers' 'User-Agent,Keep-Alive,Content-Type';
```

Now when html from `subsite.multisite.example.com` includes asset `http://multisite.example.com/picture.png` the server will output these headers which allow the browser to use the assets:

```
Access-Control-Allow-Origin: subsite.multisite.example.com
Access-Control-Allow-Methods: GET,POST;
Access-Control-Allow-Credentials: 'true;
Access-Control-Allow-Headers: User-Agent,Keep-Alive,Content-Type;
```

## Example: Allow all sites

If you want to allow all sites you can add `nginx/server/cors-headers.conf` with:

```
##
# Allow all other sites
##
add_header 'Access-Control-Allow-Origin' *;
add_header 'Access-Control-Allow-Methods' 'GET,POST';
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Headers' 'User-Agent,Keep-Alive,Content-Type';
```
