# This is for production docker image
FROM devgeniem/wordpress-server:php7.0

# Use port 8080 for flynn/router
ENV PORT=8080 \
    FLYNN_PROCESS_TYPE='WEB' \
    # Use these uid/gid in production by default and change them when needed
    WP_UID=10000 \
    WP_GID=10001

# Skip dynamic user creation and
# create user with ID WP_UID/WP_GID here for nginx/php-fpm
# this saves some time in the startup in production
RUN     rm -f /etc/cont-init.d/00-maybe-symlink-root \
        rm -f /etc/cont-init.d/01-create-web-user \
    &&  rm -f /etc/cont-init.d/01-init-web \
    &&  addgroup web -S -g $WP_GID \
    &&  adduser wordpress -S -G web -u $WP_UID \
    # Give user write access to /var/www/uploads
    &&  mkdir /var/www/uploads \
    &&  chown wordpress:web -R /var/www/uploads

##
# Install things in certain order to allow better caching
# Stuff that changes only rarely should be prioritized first
##

## Install web root files
COPY web/*.php /var/www/project/web/
## Install wp core
COPY web/wp /var/www/project/web/wp
## Install scripts
COPY scripts /var/www/project/scripts
# Install database migration config
COPY phinx.yml /var/www/project/phinx.yml
## Install database migrations and seeds
COPY db /var/www/project/db
## Install nginx configs
COPY nginx /var/www/project/nginx
## Install application config
COPY config/*.php /var/www/project/config/
## Install only the config that we want for the image and nothing else
COPY config/environments/staging.php /var/www/project/config/environments/
COPY config/environments/production.php /var/www/project/config/environments/
## Install vendor
COPY vendor /var/www/project/vendor
## Install cronjobs
COPY tasks.cron /var/www/project/
## Install wp-content
COPY web/app/*.php /var/www/project/web/app/
COPY web/app/languages /var/www/project/web/app/languages
COPY web/app/mu-plugins /var/www/project/web/app/mu-plugins
COPY web/app/plugins /var/www/project/web/app/plugins
COPY web/app/themes /var/www/project/web/app/themes

# TODO:
# Nginx needs to own the files so that it can read the assets
# Wordpress should be run with different user and nginx with different user
# Check that web:wordpress user doesn't have write access anywhere but into uploads
#RUN chown root:root -R /var/www/project \
#    && chmod go-wx -R /var/www/project



