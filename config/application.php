<?php
/**
 * This file contains WordPress config and replaces the usual wp-config.php
 *
 * @package devgeniem/wp-project
 */

$root_dir = dirname( __DIR__ );
$webroot_dir = $root_dir . '/web';

/**
 * Expose global env() function from oscarotero/env
 */
Env::init( );

/**
 * Use Dotenv to set required environment variables and load .env file in root
 * Most of ENV are set from docker environment
 */
$dotenv = new Dotenv\Dotenv( $root_dir );
if ( file_exists( $root_dir . '/.env' ) ) {
    $dotenv->load();
}

/**
 * Set up our global environment constant and load its config first
 * Default: development
 */
define( 'WP_ENV', strtolower( env( 'WP_ENV' ) ) ?: 'development' );

$env_config = __DIR__ . '/environments/' . WP_ENV . '.php';

if ( file_exists( $env_config ) ) {
    include_once $env_config;
}

/**
 * Set URLs for WP
 * Deduct them from request parameters if developer didn't set them explicitly
 * We can always just use nginx to redirect aliases to canonical url
 * This helps changing between dev->stage->production
 */
if ( defined( 'WP_HOME' ) ) {
    define( 'WP_HOME', env( 'WP_HOME' ) );
} elseif ( defined( 'REQUEST_SCHEME' ) and defined( 'HTTP_HOST' ) ) {
    define( 'WP_HOME', env( 'REQUEST_SCHEME' ) . '://' . env( 'HTTP_HOST' ) );
}

if ( defined( 'WP_SITEURL' ) ) {
    define( 'WP_SITEURL', env( 'WP_SITEURL' ) );
} elseif ( defined( 'REQUEST_SCHEME' ) and defined( 'HTTP_HOST' ) ) {
    define( 'WP_SITEURL', env( 'REQUEST_SCHEME' ) . '://' . env( 'HTTP_HOST' ) );
}

/**
 * Custom Content Directory
 */
define( 'CONTENT_DIR', '/app' );
define( 'WP_CONTENT_DIR', $webroot_dir . CONTENT_DIR );
define( 'WP_CONTENT_URL', WP_HOME . CONTENT_DIR );

/**
 * DB settings - Use DB_NAME, DB_USER, DB_PASSWORD, DB_HOST first
 * but fallback to docker container links
 */
define( 'DB_NAME', env( 'DB_NAME' ) ?: env( 'DB_ENV_MYSQL_PASSWORD' ) );
define( 'DB_USER', env( 'DB_USER' ) ?: env( 'DB_ENV_MYSQL_USER' ) );
define( 'DB_HOST', env( 'DB_HOST' ) ?: env( 'DB_PORT_3306_TCP_ADDR' ) );
define( 'DB_PASSWORD', env( 'DB_PASSWORD' ) ?: env( 'DB_ENV_MYSQL_PASSWORD' ) );
define( 'DB_CHARSET', env( 'DB_CHARSET' ) ?: 'utf8mb4' );
define( 'DB_COLLATE', env( 'DB_COLLATE' ) ?: 'utf8mb4_swedish_ci' );
$table_prefix = env( 'DB_PREFIX' ) ?: 'wp_';

/**
 * Use redis for object cache
 */
define( 'WP_REDIS_CLIENT', env( 'WP_REDIS_CLIENT' ) );
define( 'WP_REDIS_HOST', env( 'REDIS_HOST' ) ?: env( 'REDIS_PORT_6379_TCP_ADDR' ) );
// Local enviroment uses REDIS_PORT=tcp://172.17.0.6:6379 and this fixes it.
$redis_tmp_port = explode( ':', env( 'REDIS_PORT' ) );
define( 'WP_REDIS_PORT', env( 'REDIS_PORT' ) ? intval( end( $redis_tmp_port ) ) : 6379 );
unset( $redis_tmp_port );

define( 'WP_REDIS_PASSWORD', env( 'REDIS_PASSWORD' ) ?: '' );
define( 'WP_REDIS_DATABASE', env( 'WP_REDIS_DATABASE' ) ?: '0' );
define( 'WP_CACHE_KEY_SALT', env( 'WP_CACHE_KEY_SALT' ) ?: 'wp_' );

/**
 * Authentication Unique Keys and Salts
 */
define( 'AUTH_KEY', env( 'AUTH_KEY' ) );
define( 'SECURE_AUTH_KEY', env( 'SECURE_AUTH_KEY' ) );
define( 'LOGGED_IN_KEY', env( 'LOGGED_IN_KEY' ) );
define( 'NONCE_KEY', env( 'NONCE_KEY' ) );
define( 'AUTH_SALT', env( 'AUTH_SALT' ) );
define( 'SECURE_AUTH_SALT', env( 'SECURE_AUTH_SALT' ) );
define( 'LOGGED_IN_SALT', env( 'LOGGED_IN_SALT' ) );
define( 'NONCE_SALT', env( 'NONCE_SALT' ) );

/**
 * Custom Settings
 */
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'DISABLE_WP_CRON', env( 'DISABLE_WP_CRON' ) ?: false );
define( 'DISALLOW_FILE_EDIT', true );
define( 'FS_METHOD', 'direct' );

/**
 * Change uploads directory so that we can use glusterfs (or other replication) more easily
 * Note: this is only tested in single site installation
 * Uses: web/app/mu-plugins/moved-uploads.php
 */
define( 'WP_UPLOADS_DIR', env( 'WP_UPLOADS_DIR' ) ?: '/data/uploads' );
define( 'WP_UPLOADS_URL', env( 'WP_UPLOADS_URL' ) ?: WP_HOME . '/uploads' );

/**
 * Select default theme which is activated during project startup
 * Use this when the project has default theme to use.
 */

// @codingStandardsIgnoreStart
//define( 'WP_DEFAULT_THEME' ,'THEMENAME' );
// @codingStandardsIgnoreEnd

/**
 * Define newsletter plugin logging into php logging directory
 * Uses: https://wordpress.org/plugins/newsletter/
 */
define( 'NEWSLETTER_LOG_DIR', dirname( ini_get( 'error_log' ) ) . '/newsletter/' );

/**
 * Disables polylang cookies and allows better caching
 * Uses: https://wordpress.org/plugins/polylang/
 */
define( 'PLL_COOKIE', false );

/**
 * Always log errors
 */
ini_set( 'log_errors', 'On' );



/**
 * Bootstrap WordPress
 */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', $webroot_dir . '/wp/' );
}
