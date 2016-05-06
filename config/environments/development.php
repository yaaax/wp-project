<?php
/**
 * Development enviroment config
 *
 * @package devgeniem/wp-project
 */

define( 'SAVEQUERIES', true );
define( 'WP_DEBUG', true );
define( 'SCRIPT_DEBUG', true );

/**
 * We use onnimonni/signaler for https in local development
 */
define( 'FORCE_SSL_ADMIN', true );
