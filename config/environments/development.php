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

/**
 * Enable Whoops errors in all situations
 * - This forces us to fix all warnings&errors
 */
if ( ! defined( 'WP_CLI' ) && class_exists( '\Whoops\Run' ) ) {
    $whoops = new \Whoops\Run;
    $whoops->pushHandler( new \Whoops\Handler\PrettyPageHandler );
    $whoops->register();
}
