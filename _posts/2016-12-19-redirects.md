---
layout: page
title: "Redirects"
category: nginx
date: 2016-12-19 23:00:33
order: 2
---

This page shows how to add redirects for the nginx running inside the container.

```
# Create directory for http rules if it doesn't exist already
$ mkdir -p nginx/http
```

## Example: Redirect www.example.se -> www.example.com/sv/

Most performant way to do redirects is to create `nginx/http/redirects.conf.tmpl` file with these contents:

```
##
# Redirect example.se -> example.com/sv/
##
server {
    listen ${PORT};

    server_name example.se www.example.se;

    return 301 https://www.example.com/sv/;
}
```

This adds new vhost for nginx which automatically gets the **http** $PORT from env.
