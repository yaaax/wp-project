# Nginx includes in wp-project
## Server
All files matching 'server/*.conf' will be included to server block {} in nginx in docker container.

## Http
All files matching 'http/*.conf' will be included to http block {} in nginx in docker container.
For example you can use this to include [ngx_http_geoip_module](http://nginx.org/en/docs/http/ngx_http_geoip_module.html) directives to filter out ip addresses allowed in wp-admin.
