---
layout: page
title: "Custom includes"
category: nginx
date: 2016-11-29 12:33:57
order: 1
---

You can add custom nginx conf files into the projects nginx folder. The folder can be empty and nginx should still work.

You can have as many `.conf` files in the supported locations as you want to.

Here's example folder structure which has includes which are applied for all environments as well as environment specific config.
```
nginx
    |-- environments
    |   |-- development
    |   |   |-- http
    |   |   |   `-- custom.conf
    |   |   `-- server
    |   |       `-- basic-auth.conf.tmpl
    |   |-- production
    |   |   |-- http
    |   |   |   `-- custom.conf
    |   |   `-- server
    |   |       `-- something.conf
    |   `-- staging
    |       |-- http
    |       |   `-- custom.conf
    |       `-- server
    |           `-- basic-auth.conf.tmpl
    |-- http
    |   `-- cors-map.conf
    |-- readme.md
    `-- server
        |-- additions.conf
        `-- security.conf
```

## How do nginx include files work?
The main `/etc/nginx/nginx.conf` inside docker container has these `include` directives:
```
http {
    ...
    include ${NGINX_INCLUDE_DIR}/http/*.conf;
    include ${NGINX_INCLUDE_DIR}/environments/${WP_ENV}/http/*.conf;
    ...
    server {
        ...
        include ${NGINX_INCLUDE_DIR}/server/*.conf;
        include ${NGINX_INCLUDE_DIR}/environments/${WP_ENV}/server/*.conf;
        ...
    }
    ...
}
```

by placing files in `nginx/{http,server}/*.conf` folder you can add custom configs in different nginx contexts.

This structure is needed because some nginx directives like [map](http://nginx.org/en/docs/http/ngx_http_map_module.html) will only work in http context.

## Environment specific configuration ( development / testing / staging / production )
You can add environment specific configs in `nginx/environments/` folder.

Environment is read from `$WP_ENV` variable so for example for `WP_ENV=staging` the final folder would need to be `nginx/environments/staging/http` for http context and `nginx/environments/staging/server` for server context.
