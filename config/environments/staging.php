<?php
/**
 * Staging enviroment config
 *
 * @package devgeniem/wp-project
 */

ini_set( 'display_errors', 0 );
define( 'WP_DEBUG_DISPLAY', false );
define( 'SCRIPT_DEBUG', false );

// This disables all file modifications including updates.
define( 'DISALLOW_FILE_MODS', true );

/**
 * Always use HTTPS in admin
 */
define( 'FORCE_SSL_ADMIN', true );
